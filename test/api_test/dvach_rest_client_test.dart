import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/domain/models/api/dvach/board_dvach_api_model.dart';

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

  group('Thread API', () {});
}
