// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:treechan/data/board_fetcher.dart' as _i3;
import 'package:treechan/data/history_database.dart' as _i5;
import 'package:treechan/data/response_handler.dart' as _i6;
import 'package:treechan/data/rest/rest_client.dart' as _i9;
import 'package:treechan/data/thread/thread_loader.dart' as _i7;
import 'package:treechan/data/thread/thread_refresher.dart' as _i8;
import 'package:treechan/utils/constants/enums.dart' as _i4;

const String _prod = 'prod';
const String _test = 'test';
const String _dev = 'dev';

// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.factoryParam<_i3.IBoardFetcher, _i4.Imageboard, String?>(
    (
      imageboard,
      assetPath,
    ) =>
        _i3.BoardFetcher(
      imageboard: imageboard,
      assetPath: assetPath,
    ),
    registerFor: {_prod},
  );
  gh.factoryParam<_i3.IBoardFetcher, _i4.Imageboard, String>(
    (
      imageboard,
      assetPath,
    ) =>
        _i3.MockBoardFetcher(
      imageboard: imageboard,
      assetPath: assetPath,
    ),
    registerFor: {
      _test,
      _dev,
    },
  );
  gh.lazySingleton<_i5.IHistoryDatabase>(
    () => _i5.HistoryDatabase(),
    registerFor: {
      _test,
      _dev,
      _prod,
    },
  );
  gh.lazySingleton<_i6.IResponseHandler>(
    () => _i6.ResponseHandler(),
    registerFor: {
      _test,
      _dev,
      _prod,
    },
  );
  gh.factoryParam<_i7.IThreadRemoteLoader, _i4.Imageboard, String>(
    (
      imageboard,
      assetPath,
    ) =>
        _i7.ThreadRemoteLoader(
      imageboard: imageboard,
      assetPath: assetPath,
    ),
    registerFor: {_prod},
  );
  gh.factoryParam<_i7.IThreadRemoteLoader, _i4.Imageboard, String>(
    (
      imageboard,
      assetPath,
    ) =>
        _i7.MockThreadRemoteLoader(
      imageboard: imageboard,
      assetPath: assetPath,
    ),
    registerFor: {
      _test,
      _dev,
    },
  );
  gh.factoryParam<_i8.IThreadRemoteRefresher, _i4.Imageboard, dynamic>(
    (
      imageboard,
      assetPaths,
    ) =>
        _i8.ThreadRemoteRefresher(
      imageboard: imageboard,
      assetPaths: assetPaths,
    ),
    registerFor: {_prod},
  );
  gh.factoryParam<_i8.IThreadRemoteRefresher, _i4.Imageboard, List<String>>(
    (
      imageboard,
      assetPaths,
    ) =>
        _i8.MockThreadRemoteRefresher(
      imageboard: imageboard,
      assetPaths: assetPaths,
    ),
    registerFor: {
      _test,
      _dev,
    },
  );
  gh.factoryParam<_i9.RestClient, _i10.Dio, dynamic>(
    (
      dio,
      _,
    ) =>
        _i9.DvachRestClient(dio),
    instanceName: 'dvach',
    registerFor: {
      _test,
      _dev,
      _prod,
    },
  );
  return getIt;
}
