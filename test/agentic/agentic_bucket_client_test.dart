import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import '../client_mock_test.dart'
    show MockSendRequest, MockProcessRequest, make403Response;

Configuration agenticConfig() => Configuration(
  region: 'cn-hangzhou',
  accountId: '137',
  retryer: NopRetryer(),
  credentialsProvider: StaticCredentialsProvider(
    accessKeyId: 'ak',
    accessKeySecret: 'sk',
  ),
);

ResponseMessage xmlResponse(String xml, [int status = 200]) => ResponseMessage(
  statusCode: status,
  headers: {
    'x-oss-request-id': 'request-id',
    'content-type': 'application/xml',
  },
  content: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
);

Matcher clientCode(String code) =>
    isA<ClientError>().having((e) => e.code, 'code', code);

/// Freezes time and records real V4 canonical requests; does not replace signature computation.
class FixedRecordingSigner extends SignerV4 {
  final contexts = <SigningContext>[];
  final canonicals = <String>[];
  @override
  Future<RequestMessage> sign(RequestMessage request, SigningContext context) {
    context.signTime = DateTime.utc(2024, 1, 1);
    contexts.add(context);
    return super.sign(request, context);
  }

  @override
  String calcCanonicalRequest(
    RequestMessage request,
    String resourcePath,
    Map<String, String> headers,
    List<String> additionalHeaders,
  ) {
    final value = super.calcCanonicalRequest(
      request,
      resourcePath,
      headers,
      additionalHeaders,
    );
    canonicals.add(value);
    return value;
  }
}

void main() {
  group('AgenticBucket API', () {
    final cases =
        <
          (
            String,
            String,
            Set<String>,
            String,
            int,
            Future<ResultModel> Function(AgenticBucketClient),
          )
        >[
          (
            'create',
            'PUT',
            {'agenticBucket'},
            '',
            200,
            (c) => c.createAgenticBucket(
              CreateAgenticBucketRequest(bucket: 'prefix'),
            ),
          ),
          (
            'delete',
            'DELETE',
            {'agenticBucket'},
            '',
            204,
            (c) => c.deleteAgenticBucket(
              DeleteAgenticBucketRequest(bucket: 'prefix'),
            ),
          ),
          (
            'get',
            'GET',
            {'agenticBucket'},
            '<AgenticBucketInfo><Name>physical</Name><Owner>137</Owner></AgenticBucketInfo>',
            200,
            (c) =>
                c.getAgenticBucket(GetAgenticBucketRequest(bucket: 'prefix')),
          ),
          (
            'list',
            'GET',
            {'agenticBucket'},
            '<ListAgenticBucketsResult><IsTruncated>false</IsTruncated></ListAgenticBucketsResult>',
            200,
            (c) => c.listAgenticBuckets(ListAgenticBucketsRequest()),
          ),
          (
            'status',
            'PUT',
            {'agenticBucket', 'status'},
            '',
            200,
            (c) => c.putAgenticBucketStatus(
              PutAgenticBucketStatusRequest(
                bucket: 'prefix',
                status: 'Disabled',
              ),
            ),
          ),
          (
            'spaces',
            'GET',
            {'agenticBucket', 'bucketSpace'},
            '<ListBucketSpacesResult><IsTruncated>false</IsTruncated></ListBucketSpacesResult>',
            200,
            (c) =>
                c.listBucketSpaces(ListBucketSpacesRequest(bucket: 'prefix')),
          ),
        ];
    for (final entry in cases) {
      test('${entry.$1} method, query, metadata, and body', () async {
        final mock = MockSendRequest()
          ..addResponse(xmlResponse(entry.$4, entry.$5));
        final client = AgenticBucketClient(agenticConfig(), [
          (o) => o.executeMW = mock,
        ]);
        addTearDown(client.dispose);
        final result = await entry.$6(client);
        final request = mock.requests.single;
        expect(result.statusCode, entry.$5);
        expect(result.requestId, 'request-id');
        expect(request.method, entry.$2);
        expect(request.requestUri.queryParameters.keys.toSet(), entry.$3);
        expect(
          request.requestUri.host,
          entry.$1 == 'list'
              ? 'oss-cn-hangzhou.aliyuncs.com'
              : 'prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com',
        );
        expect(request.headers['content-type'], 'application/xml');
        expect(
          request.headers['Authorization'],
          startsWith('OSS4-HMAC-SHA256'),
        );
        if (entry.$1 == 'status') {
          final data = (await request.content!.readData())!;
          expect(utf8.decode(data), contains('<Status>Disabled</Status>'));
          expect(
            request.headers['content-md5'],
            base64Encode(md5.convert(data).bytes),
          );
        } else {
          expect(request.content, isNull);
          expect(request.headers['content-md5'], '1B2M2Y8AsgTpgAmY7PhCfg==');
        }
      });
      test('${entry.$1} does not swallow server errors', () async {
        final mock = MockSendRequest()..addResponse(make403Response());
        final client = AgenticBucketClient(agenticConfig(), [
          (o) => o.executeMW = mock,
        ]);
        addTearDown(client.dispose);
        await expectLater(
          entry.$6(client),
          throwsA(
            isA<ServerError>()
                .having((e) => e.code, 'code', 'InvalidAccessKeyId')
                .having((e) => e.statusCode, 'status', 403),
          ),
        );
      });
    }

    test('all required fields validated before sending request', () async {
      final mock = MockSendRequest();
      final client = AgenticBucketClient(agenticConfig(), [
        (o) => o.executeMW = mock,
      ]);
      addTearDown(client.dispose);
      final calls = <Future<Object> Function()>[
        () => client.createAgenticBucket(CreateAgenticBucketRequest()),
        () => client.deleteAgenticBucket(DeleteAgenticBucketRequest()),
        () => client.getAgenticBucket(GetAgenticBucketRequest()),
        () => client.listBucketSpaces(ListBucketSpacesRequest()),
        () => client.putAgenticBucketStatus(
          PutAgenticBucketStatusRequest(status: 'Enabled'),
        ),
        () => client.putAgenticBucketStatus(
          PutAgenticBucketStatusRequest(bucket: 'prefix'),
        ),
      ];
      for (final call in calls) {
        await expectLater(call(), throwsA(clientCode('ParameterError')));
      }
      expect(mock.requests, isEmpty);
    });

    test('common properties and operation options pass through', () async {
      final client = AgenticBucketClient(agenticConfig(), [
        (o) => o.executeMW = MockProcessRequest(
          process: (r, c) async {
            expect(r.headers['x-custom'], 'value');
            expect(r.requestUri.queryParameters['extra'], 'a+b c');
            expect(c.retryMaxAttempts, 1);
            expect(c.readWriteTimeout, 12000);
            return xmlResponse(
              '<ListAgenticBucketsResult><IsTruncated>false</IsTruncated></ListAgenticBucketsResult>',
            );
          },
        ),
      ]);
      addTearDown(client.dispose);
      await client.listAgenticBuckets(
        ListAgenticBucketsRequest(
          commonProp: RequestModelProp(
            headers: {'X-Custom': 'value'},
            parameters: {'extra': 'a+b c'},
          ),
        ),
        OperationOptions(
          retryMaxAttempts: 1,
          readWriteTimeout: const Duration(seconds: 12),
        ),
      );
    });

    for (final style in AddressStyleType.values) {
      test('Agentic addressing $style and repeated input unchanged', () async {
        final signer = FixedRecordingSigner();
        final mock = MockSendRequest()
          ..addResponse(xmlResponse(''))
          ..addResponse(xmlResponse(''));
        final client = AgenticBucketClient(agenticConfig().withSigner(signer), [
          (o) {
            o.addressStyle = style;
            o.executeMW = mock;
          },
        ]);
        addTearDown(client.dispose);
        final input = OperationInput(
          method: 'GET',
          bucket: 'prefix',
          key: '目录/a+b c/%',
          parameters: {'q': 'a+b c'},
        );
        await client.invokeOperation(input);
        await client.invokeOperation(input);
        final base = style == AddressStyleType.path
            ? 'https://oss-cn-hangzhou.aliyuncs.com/prefix-137-cn-hangzhou-ab-apsr/'
            : 'https://${style == AddressStyleType.virtualHostedAlias ? 'prefix-alias-ab-apsr' : 'prefix-137-cn-hangzhou-ab-apsr'}.oss-cn-hangzhou.aliyuncs.com/';
        expect(
          mock.requests.first.requestUri.toString(),
          '$base%E7%9B%AE%E5%BD%95/a%2Bb%20c/%25?q=a%2Bb%20c',
        );
        expect(mock.requests.last.requestUri, mock.requests.first.requestUri);
        expect(
          signer.contexts.map((c) => c.bucket),
          everyElement('prefix-137-cn-hangzhou-ab-apsr'),
        );
        expect(input.bucket, 'prefix');
        expect(input.headers, isEmpty);
        expect(input.parameters, {'q': 'a+b c'});
      });
    }

    test('alias fixed V4 canonical request uses physical bucket name', () async {
      final signer = FixedRecordingSigner();
      final mock = MockSendRequest()
        ..addResponse(
          xmlResponse(
            '<AgenticBucketInfo><Name>physical</Name></AgenticBucketInfo>',
          ),
        );
      final client = AgenticBucketClient(
        agenticConfig().withUseVirtualHostedAlias(true).withSigner(signer),
        [(o) => o.executeMW = mock],
      );
      addTearDown(client.dispose);
      await client.getAgenticBucket(GetAgenticBucketRequest(bucket: 'prefix'));
      const canonical =
          'GET\n/prefix-137-cn-hangzhou-ab-apsr/\nagenticBucket\n'
          'content-md5:1B2M2Y8AsgTpgAmY7PhCfg==\ncontent-type:application/xml\n'
          'x-oss-content-sha256:UNSIGNED-PAYLOAD\nx-oss-date:20240101T000000Z\n\n\nUNSIGNED-PAYLOAD';
      expect(signer.canonicals.single, canonical);
      expect(
        signer.contexts.single.stringToSign,
        'OSS4-HMAC-SHA256\n20240101T000000Z\n20240101/cn-hangzhou/oss/aliyun_v4_request\n${sha256.convert(utf8.encode(canonical))}',
      );
      expect(
        mock.requests.single.requestUri.host,
        startsWith('prefix-alias-ab-apsr.'),
      );
    });

    for (final alias in [false, true]) {
      final maxPrefix = alias ? 49 : 39;
      for (final length in [maxPrefix, maxPrefix + 1]) {
        test('label length alias=$alias prefix=$length', () async {
          final mock = MockSendRequest()..addResponse(xmlResponse(''));
          final client = AgenticBucketClient(
            agenticConfig().withUseVirtualHostedAlias(alias),
            [(o) => o.executeMW = mock],
          );
          addTearDown(client.dispose);
          final call = client.createAgenticBucket(
            CreateAgenticBucketRequest(bucket: 'a' * length),
          );
          if (length == maxPrefix) {
            await call;
            expect(
              mock.requests.single.requestUri.host.split('.').first.length,
              63,
            );
          } else {
            await expectLater(call, throwsA(clientCode('ValidationError')));
            expect(mock.requests, isEmpty);
          }
        });
      }
    }

    test(
      'path allows long physical names and preserves trailing slash on bucket path',
      () async {
        final mock = MockSendRequest()..addResponse(xmlResponse(''));
        final client = AgenticBucketClient(
          agenticConfig().withUsePathStyle(true),
          [(o) => o.executeMW = mock],
        );
        addTearDown(client.dispose);
        await client.createAgenticBucket(
          CreateAgenticBucketRequest(bucket: 'a' * 63),
        );
        expect(
          mock.requests.single.requestUri.path,
          '/${'a' * 63}-137-cn-hangzhou-ab-apsr/',
        );
      },
    );

    for (final alias in [false, true]) {
      for (final account in <String?>[null, '']) {
        test(
          'with bucket requires AccountId, alias=$alias account=$account',
          () async {
            final config = agenticConfig()..accountId = account;
            config.useVirtualHostedAlias = alias;
            final mock = MockSendRequest();
            final client = AgenticBucketClient(config, [
              (o) => o.executeMW = mock,
            ]);
            addTearDown(client.dispose);
            await expectLater(
              client.createAgenticBucket(
                CreateAgenticBucketRequest(bucket: 'prefix'),
              ),
              throwsA(clientCode('ParameterError')),
            );
            expect(mock.requests, isEmpty);
          },
        );
      }
      test(
        'without bucket region listing does not require AccountId, alias=$alias',
        () async {
          final config = agenticConfig()..accountId = null;
          config.useVirtualHostedAlias = alias;
          final mock = MockSendRequest()
            ..addResponse(
              xmlResponse(
                '<ListAgenticBucketsResult><IsTruncated>false</IsTruncated></ListAgenticBucketsResult>',
              ),
            );
          final client = AgenticBucketClient(config, [
            (o) => o.executeMW = mock,
          ]);
          addTearDown(client.dispose);
          await client.listAgenticBuckets(ListAgenticBucketsRequest());
          expect(
            mock.requests.single.requestUri.host,
            'oss-cn-hangzhou.aliyuncs.com',
          );
        },
      );
    }

    test(
      'with endpoint but missing Region still reports required error',
      () async {
        final config = agenticConfig()..region = '';
        config.endpoint = 'https://example.com';
        final client = AgenticBucketClient(config);
        addTearDown(client.dispose);
        await expectLater(
          client.createAgenticBucket(
            CreateAgenticBucketRequest(bucket: 'prefix'),
          ),
          throwsA(clientCode('ParameterError')),
        );
      },
    );

    test(
      'scoped actions installed last, preserving user endpoint and port',
      () async {
        final mock = MockSendRequest()..addResponse(xmlResponse(''));
        final client = AgenticBucketClient(agenticConfig(), [
          (o) {
            o.endpoint = Uri.parse('http://example.com:8080');
            o.addressStyle = AddressStyleType.virtualHostedAlias;
            o.bucketNameResolver = (_) => 'wrong';
            o.endpointProvider = (_) => 'https://wrong.example';
            o.executeMW = mock;
          },
        ]);
        addTearDown(client.dispose);
        await client.createAgenticBucket(
          CreateAgenticBucketRequest(bucket: 'prefix'),
        );
        expect(
          mock.requests.single.requestUri.toString(),
          'http://prefix-alias-ab-apsr.example.com:8080/?agenticBucket=',
        );
      },
    );
  });
}
