import 'dart:convert';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import '../client_mock_test.dart' show MockSendRequest, MockProcessRequest;
import 'agentic_bucket_client_test.dart'
    show agenticConfig, xmlResponse, clientCode, FixedRecordingSigner;

void main() {
  for (final style in AddressStyleType.values) {
    test(
      'BucketSpace object operations and presigning share routing: $style',
      () async {
        final signer = FixedRecordingSigner();
        final mock = MockSendRequest()..addResponse(xmlResponse('object'));
        final client =
            BucketSpaceClient.make(agenticConfig().withSigner(signer), [
              (o) {
                o.executeMW = mock;
                o.addressStyle = style;
              },
            ]);
        addTearDown(client.dispose);
        final request = GetObjectRequest(bucket: 'prefix', key: 'dir/a+b c');
        final result = await client.getObject(request);
        expect(utf8.decode((await result.body!.readData())!), 'object');
        final signed = await client.presignGetObject(
          request,
          DateTime.utc(2024, 1, 1, 0, 15),
        );
        final uri = Uri.parse(signed.url);
        expect(uri.host, mock.requests.single.requestUri.host);
        expect(uri.path, mock.requests.single.requestUri.path);
        final label = style == AddressStyleType.virtualHostedAlias
            ? 'prefix-alias-bs-apsr'
            : 'prefix-137-cn-hangzhou-bs-apsr';
        if (style == AddressStyleType.path) {
          expect(uri.host, 'oss-cn-hangzhou.aliyuncs.com');
          expect(uri.path, '/prefix-137-cn-hangzhou-bs-apsr/dir/a%2Bb%20c');
        } else {
          expect(uri.host, '$label.oss-cn-hangzhou.aliyuncs.com');
        }
        expect(uri.queryParameters['x-oss-signature'], isNotEmpty);
        expect(
          signer.contexts.map((c) => c.bucket),
          everyElement('prefix-137-cn-hangzhou-bs-apsr'),
        );
        expect(
          signer.canonicals.last,
          contains('\n/prefix-137-cn-hangzhou-bs-apsr/dir/a%2Bb%20c\n'),
        );
        expect(request.bucket, 'prefix');
        expect(request.key, 'dir/a+b c');
      },
    );
  }

  for (final endpoint in ['http://127.0.0.1:8080', 'http://[::1]:8080']) {
    test('IP endpoint auto path: $endpoint', () async {
      final mock = MockSendRequest()..addResponse(xmlResponse(''));
      final client = BucketSpaceClient.make(
        agenticConfig().withEndpoint(endpoint).withUseVirtualHostedAlias(true),
        [(o) => o.executeMW = mock],
      );
      addTearDown(client.dispose);
      await client.invokeOperation(
        OperationInput(method: 'GET', bucket: 'space'),
      );
      expect(
        mock.requests.single.requestUri.toString(),
        '$endpoint/space-137-cn-hangzhou-bs-apsr/',
      );
    });
  }

  test(
    'create BucketSpace uses parent physical name, no XML generated',
    () async {
      final mock = MockSendRequest()..addResponse(xmlResponse(''));
      final client = BucketSpaceClient.make(agenticConfig(), [
        (o) => o.executeMW = mock,
      ]);
      addTearDown(client.dispose);
      await client.putBucket(
        PutBucketRequest(
          bucket: 'space',
          agenticBucket: 'parent-137-cn-hangzhou-ab-apsr',
        ),
      );
      final request = mock.requests.single;
      expect(
        request.requestUri.host,
        'space-137-cn-hangzhou-bs-apsr.oss-cn-hangzhou.aliyuncs.com',
      );
      expect(
        request.headers['x-oss-agentic-bucket'],
        'parent-137-cn-hangzhou-ab-apsr',
      );
      expect(request.content, isNull);
      expect(request.headers['content-md5'], isNull);
    },
  );

  test(
    'shared configuration User-Agent and account isolation, interleaved requests do not interfere',
    () async {
      final config = agenticConfig().withUserAgent('app');
      final seen = <(String?, String, String?)>[];
      final middleware = MockProcessRequest(
        process: (r, c) async {
          await Future<void>.delayed(Duration.zero);
          seen.add((
            c.signingContext!.bucket,
            r.headers['user-agent']!,
            r.headers['x-custom'],
          ));
          return xmlResponse('');
        },
      );
      final plain = Client(config, [(o) => o.executeMW = middleware]);
      final scoped = BucketSpaceClient.make(config, [
        (o) => o.executeMW = middleware,
      ]);
      final manager = AgenticBucketClient(config, [
        (o) => o.executeMW = middleware,
      ]);
      addTearDown(plain.dispose);
      addTearDown(scoped.dispose);
      addTearDown(manager.dispose);
      expect(config.userAgent, 'app');
      config.accountId = '999';
      await Future.wait([
        plain.invokeOperation(
          OperationInput(
            method: 'GET',
            bucket: 'ordinary',
            headers: {'x-custom': 'plain'},
          ),
        ),
        scoped.invokeOperation(
          OperationInput(
            method: 'GET',
            bucket: 'space',
            headers: {'x-custom': 'space'},
          ),
        ),
        manager.invokeOperation(
          OperationInput(
            method: 'GET',
            bucket: 'parent',
            headers: {'x-custom': 'parent'},
          ),
        ),
      ]);
      expect(seen.map((v) => v.$1).toSet(), {
        'ordinary',
        'space-137-cn-hangzhou-bs-apsr',
        'parent-137-cn-hangzhou-ab-apsr',
      });
      expect(
        seen.singleWhere((v) => v.$3 == 'plain').$2,
        isNot(contains('agentic-client')),
      );
      expect(
        seen.where((v) => v.$3 != 'plain').map((v) => v.$2),
        everyElement(contains('agentic-client/app')),
      );
    },
  );

  test(
    'retry does not re-concatenate, subsequent presign still uses original input',
    () async {
      final mock = MockSendRequest()
        ..addResponse(
          xmlResponse(
            '<Error><Code>InternalError</Code><Message>retry</Message><RequestId>id</RequestId></Error>',
            500,
          ),
        )
        ..addResponse(xmlResponse(''));
      final signer = FixedRecordingSigner();
      final client = BucketSpaceClient.make(
        agenticConfig()
            .withRetryer(StandardRetryer(maxAttempt: 2))
            .withSigner(signer),
        [(o) => o.executeMW = mock],
      );
      addTearDown(client.dispose);
      final input = OperationInput(
        operationName: 'GetObject',
        method: 'GET',
        bucket: 'space',
        key: 'key',
      );
      await client.invokeOperation(input);
      expect(mock.requests.length, 2);
      final signed = await client.presignInner(input);
      expect(signed.url, contains('space-137-cn-hangzhou-bs-apsr.'));
      expect(input.bucket, 'space');
      expect(
        signer.contexts.map((c) => c.bucket),
        everyElement('space-137-cn-hangzhou-bs-apsr'),
      );
    },
  );

  for (final alias in [false, true]) {
    for (final length in [alias ? 49 : 39, alias ? 50 : 40]) {
      test('BucketSpace label boundary alias=$alias prefix=$length', () async {
        final client = BucketSpaceClient.make(
          agenticConfig().withUseVirtualHostedAlias(alias),
        );
        addTearDown(client.dispose);
        final call = client.presignGetObject(
          GetObjectRequest(bucket: 'a' * length, key: 'key'),
        );
        if (length == (alias ? 49 : 39)) {
          expect(Uri.parse((await call).url).host.split('.').first.length, 63);
        } else {
          await expectLater(call, throwsA(clientCode('ValidationError')));
        }
      });
    }
  }

  for (final account in ['abc', '']) {
    test(
      'BucketSpace presign also performs account validation: $account',
      () async {
        final client = BucketSpaceClient.make(
          agenticConfig()
              .withAccountId(account)
              .withUseVirtualHostedAlias(true),
        );
        addTearDown(client.dispose);
        await expectLater(
          client.presignGetObject(
            GetObjectRequest(bucket: 'space', key: 'key'),
          ),
          throwsA(
            clientCode(account.isEmpty ? 'ParameterError' : 'ValidationError'),
          ),
        );
      },
    );
  }
}
