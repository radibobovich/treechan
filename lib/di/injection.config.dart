// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:treechan/data/history_database.dart' as _i3;
import 'package:treechan/data/thread/response_handler.dart' as _i4;
import 'package:treechan/data/thread/thread_loader.dart' as _i5;
import 'package:treechan/data/thread/thread_refresher.dart' as _i6;

const String _test = 'test';
const String _dev = 'dev';
const String _prod = 'prod';

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
  gh.lazySingleton<_i3.IHistoryDatabase>(
    () => _i3.HistoryDatabase(),
    registerFor: {
      _test,
      _dev,
      _prod,
    },
  );
  gh.lazySingleton<_i4.IResponseHandler>(
    () => _i4.ResponseHandler(),
    registerFor: {
      _test,
      _dev,
      _prod,
    },
  );
  gh.factory<_i5.IThreadRemoteLoader>(
    () => _i5.ThreadRemoteLoader(),
    registerFor: {_prod},
  );
  gh.factoryParam<_i5.IThreadRemoteLoader, String, dynamic>(
    (
      assetPath,
      _,
    ) =>
        _i5.MockThreadRemoteLoader(assetPath: assetPath),
    registerFor: {
      _test,
      _dev,
    },
  );
  gh.factory<_i6.IThreadRemoteRefresher>(
    () => _i6.ThreadRemoteRefresher(),
    registerFor: {_prod},
  );
  gh.factoryParam<_i6.IThreadRemoteRefresher, List<String>, dynamic>(
    (
      assetPaths,
      _,
    ) =>
        _i6.MockThreadRemoteRefresher(assetPaths: assetPaths),
    registerFor: {
      _test,
      _dev,
    },
  );
  return getIt;
}
