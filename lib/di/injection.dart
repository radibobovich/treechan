import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(asExtension: false)
configureInjection(GetIt getIt, String environment) {
  init(getIt, environment: environment);
}

abstract class Env {
  static const test = 'test';
  static const dev = 'dev';
  static const prod = 'prod';
}

late String env;
