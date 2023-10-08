import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/domain/models/api/dvach/board_dvach_api_model.dart';
import 'package:treechan/domain/models/api/dvach/thread_archive_dvach_api_model.dart';

main() {
  test('Board list API test', () async {
    final client = DvachRestClient(Dio());

    final List<BoardDvachApiModel> boards = await client.getBoards();

    debugPrint(boards.length.toString());
    expect(boards.length, greaterThan(0));
  });
  group('Board API', () {
    test('Board API index test', () async {
      final client = DvachRestClient(Dio());

      BoardResponseDvachApiModel model =
          await client.getBoardIndex(boardTag: 'b');
      debugPrint(model.board.name);
      debugPrint(model.threads.length.toString());
      expect(model.threads.length, greaterThan(0));
    });

    test('Board API catalog test', () async {
      final client = DvachRestClient(Dio());

      BoardResponseDvachApiModel model =
          await client.getBoardCatalog(boardTag: 'b');
      debugPrint(model.board.name);
      debugPrint(model.threads.length.toString());
      expect(model.threads.length, greaterThan(0));
    });

    test('Board API catalog by time test', () async {
      final client = DvachRestClient(Dio());

      BoardResponseDvachApiModel model =
          await client.getBoardCatalogByTime(boardTag: 'b');

      debugPrint(model.board.name);
      debugPrint(model.threads.length.toString());
      expect(model.threads.length, greaterThan(0));
    });

    // TODO: specific page test

    test('Board API specific page test', () async {
      final client = DvachRestClient(Dio());

      BoardResponseDvachApiModel model =
          await client.getBoardPage(boardTag: 'b', page: 1);

      debugPrint(model.board.name);
      debugPrint(model.threads.length.toString());
      expect(model.threads.length, greaterThan(0));
    });
  });

  group('Thread archive API', () {
    test('Archived thread test (2016/02/13)', () async {
      final client = DvachArchiveRestClient(Dio());

      ThreadArchiveResponseDvachApiModel model = await client.loadThread(
          boardTag: 'a', date: '2016-02-13', threadId: 2656447);
      expect(model.Board, 'a');
      expect(model.threads.first.posts, isNotEmpty);
    });
    test('Archived thread test (2018/01/01)', () async {
      final client = DvachArchiveRestClient(Dio());
      ThreadArchiveResponseDvachApiModel model = await client.loadThread(
          boardTag: 'a', date: '2018-01-01', threadId: 4242071);
      expect(model.Board, 'a');
      expect(model.threads.first.posts, isNotEmpty);
    });
    test('Archived thread test (2020/05/04)', () async {
      final client = DvachArchiveRestClient(Dio());
      ThreadArchiveResponseDvachApiModel model = await client.loadThread(
          boardTag: 'a', date: '2020-05-04', threadId: 6751297);
      expect(model.Board, 'a');
      expect(model.threads.first.posts, isNotEmpty);
    });
    test('Archived thread test (2021/04/04)', () async {
      final client = DvachArchiveRestClient(Dio());
      ThreadArchiveResponseDvachApiModel model = await client.loadThread(
          boardTag: 'a', date: '2021-04-04', threadId: 7183005);
      expect(model.Board, 'a');
      expect(model.threads.first.posts, isNotEmpty);
    });
  });
}
