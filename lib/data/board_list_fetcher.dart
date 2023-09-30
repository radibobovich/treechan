import 'package:dio/dio.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/api/board_api_model.dart';
import 'package:treechan/domain/models/api/dvach/board_dvach_api_model.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../exceptions.dart';

abstract class IBoardListFetcher {
  Future<List<Board>> getBoards();
}

class BoardListFetcher implements IBoardListFetcher {
  BoardListFetcher({required this.imageboard});
  final Imageboard imageboard;
  @override
  Future<List<Board>> getBoards() async {
    final RestClient restClient =
        getIt<RestClient>(instanceName: imageboard.name, param1: _getDio());

    final List<BoardApiModel> apiModels = await restClient.getBoards();

    if (apiModels.first is BoardDvachApiModel) {
      return apiModels
          .map((model) => Board.fromDvachApi(model as BoardDvachApiModel))
          .toList();
    } else {
      throw Exception("Unknown board api model");
    }
  }
}

Dio _getDio() {
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode != null && response.statusCode != 200) {
          throw FailedResponseException(
              message:
                  'Failed to load board list. Error code: ${response.statusCode}',
              statusCode: response.statusCode!);
        }
        return handler.next(response);
      },
    ),
  );
  return dio;
}
