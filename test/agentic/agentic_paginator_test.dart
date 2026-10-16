import 'dart:async';
import 'package:dio/dio.dart' show CancelToken;
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import '../client_mock_test.dart'
    show MockSendRequest, MockProcessRequest, make403Response;
import 'agentic_bucket_client_test.dart'
    show agenticConfig, xmlResponse, clientCode;

String pageXml(
  bool spaces, {
  bool truncated = false,
  String? next,
  int page = 0,
  bool empty = false,
}) {
  final root = spaces ? 'ListBucketSpacesResult' : 'ListAgenticBucketsResult';
  final wrapper = spaces ? 'BucketSpaces' : 'AgenticBuckets';
  final item = spaces ? 'BucketSpace' : 'AgenticBucket';
  return '<$root><IsTruncated>$truncated</IsTruncated>'
      '${next == null ? '' : '<NextContinuationToken>$next</NextContinuationToken>'}'
      '<$wrapper>${empty ? '' : '<$item><Name>item$page</Name></$item>'}</$wrapper></$root>';
}

void main() {
  for (final spaces in [false, true]) {
    group(spaces ? 'BucketSpace pagination' : 'AgenticBucket pagination', () {
      dynamic makePaginator(
        AgenticBucketClient client, {
        RequestModelProp? prop,
        OperationOptions? options,
        String? token,
      }) {
        final limit = PaginatorOptions(limit: 1);
        return spaces
            ? client.listBucketSpacesPaginator(
                ListBucketSpacesRequest(
                  bucket: 'parent',
                  prefix: 'filter',
                  startAfter: 'first',
                  continuationToken: token,
                  maxKeys: 20,
                  commonProp: prop,
                ),
                options: options,
                paginatorOptions: limit,
              )
            : client.listAgenticBucketsPaginator(
                ListAgenticBucketsRequest(
                  continuationToken: token,
                  maxKeys: 20,
                  commonProp: prop,
                ),
                options: options,
                paginatorOptions: limit,
              );
      }

      test(
        'lazy, multi-page, option snapshot, and independent subscription',
        () async {
          final seen = <RequestMessage>[];
          final cancel = CancelToken();
          final options = OperationOptions(
            retryMaxAttempts: 1,
            readWriteTimeout: const Duration(seconds: 7),
            cancelToken: cancel,
          );
          final prop = RequestModelProp(
            headers: {'x-test': 'original'},
            parameters: {'extra': 'original'},
          );
          final client = AgenticBucketClient(agenticConfig(), [
            (o) => o.executeMW = MockProcessRequest(
              process: (r, c) async {
                seen.add(r);
                expect(c.retryMaxAttempts, 1);
                expect(c.readWriteTimeout, 7000);
                expect(c.cancelToken, same(cancel));
                final next = r.requestUri.queryParameters['continuation-token'];
                return xmlResponse(
                  pageXml(
                    spaces,
                    truncated: next == null,
                    next: next == null ? 'next' : null,
                    page: next == null ? 0 : 1,
                  ),
                );
              },
            ),
          ]);
          addTearDown(client.dispose);
          final paginator = makePaginator(client, prop: prop, options: options);
          prop.headers!['x-test'] = 'changed';
          prop.parameters!['extra'] = 'changed';
          options.retryMaxAttempts = 9;
          options.readWriteTimeout = const Duration(seconds: 99);
          expect(seen, isEmpty);
          final streams = [
            paginator.stream as Stream<ResultModel>,
            paginator.stream as Stream<ResultModel>,
          ];
          final results = await Future.wait(streams.map((s) => s.toList()));
          expect(results.map((r) => r.length), everyElement(2));
          expect(seen.length, 4);
          expect(
            seen
                .where(
                  (r) =>
                      r.requestUri.queryParameters['continuation-token'] ==
                      'next',
                )
                .length,
            2,
          );
          for (final sent in seen) {
            expect(sent.headers['x-test'], 'original');
            expect(sent.requestUri.queryParameters['extra'], 'original');
            expect(sent.requestUri.queryParameters['max-keys'], '1');
            if (spaces) {
              expect(sent.requestUri.queryParameters['prefix'], 'filter');
              expect(sent.requestUri.queryParameters['start-after'], 'first');
            }
          }
          expect(prop.parameters, {'extra': 'changed'});
        },
      );

      test('pause and cancel do not prefetch next page', () async {
        final mock = MockSendRequest()
          ..addResponse(
            xmlResponse(pageXml(spaces, truncated: true, next: 'next')),
          );
        final client = AgenticBucketClient(agenticConfig(), [
          (o) => o.executeMW = mock,
        ]);
        addTearDown(client.dispose);
        final iterator = StreamIterator<ResultModel>(
          makePaginator(client).stream as Stream<ResultModel>,
        );
        expect(await iterator.moveNext(), isTrue);
        await Future<void>.delayed(Duration.zero);
        expect(mock.requests.length, 1);
        await iterator.cancel();
        await Future<void>.delayed(Duration.zero);
        expect(mock.requests.length, 1);
      });

      for (final next in <String?>[null, '', 'same']) {
        test('truncated token missing or did not advance: $next', () async {
          final mock = MockSendRequest()
            ..addResponse(
              xmlResponse(pageXml(spaces, truncated: true, next: next)),
            );
          final client = AgenticBucketClient(agenticConfig(), [
            (o) => o.executeMW = mock,
          ]);
          addTearDown(client.dispose);
          final paginator = makePaginator(client, token: 'same');
          await expectLater(
            (paginator.stream as Stream<ResultModel>).toList(),
            throwsA(clientCode('PaginationError')),
          );
          expect(mock.requests.length, 1);
        });
      }

      test('network error terminates, no further pagination', () async {
        final mock = MockSendRequest()
          ..addResponse(
            xmlResponse(pageXml(spaces, truncated: true, next: 'next')),
          )
          ..addResponse(make403Response());
        final client = AgenticBucketClient(agenticConfig(), [
          (o) => o.executeMW = mock,
        ]);
        addTearDown(client.dispose);
        await expectLater(
          (makePaginator(client).stream as Stream<ResultModel>).toList(),
          throwsA(isA<ServerError>()),
        );
        expect(mock.requests.length, 2);
      });

      test('empty page finishes normally and explicit collection', () async {
        final mock = MockSendRequest()
          ..addResponse(xmlResponse(pageXml(spaces, empty: true)))
          ..addResponse(
            xmlResponse(pageXml(spaces, truncated: true, next: 'next')),
          )
          ..addResponse(xmlResponse(pageXml(spaces, page: 1)));
        final client = AgenticBucketClient(agenticConfig(), [
          (o) => o.executeMW = mock,
        ]);
        addTearDown(client.dispose);
        final paginator = makePaginator(client);
        final List<dynamic> pages = await paginator.collectAllResults();
        expect(pages.length, 1);
        final List<dynamic> items = spaces
            ? await paginator.collectAllBucketSpaces()
            : await paginator.collectAllAgenticBuckets();
        expect(items.map((dynamic item) => item.name).toList(), [
          'item0',
          'item1',
        ]);
      });
    });
  }
}
