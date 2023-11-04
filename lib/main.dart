import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:treechan/config/local_notifications.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/router.dart';
import 'config/preferences.dart';
import 'presentation/provider/page_provider.dart';
import 'presentation/provider/tab_manager.dart';
import 'presentation/screens/page_navigator.dart';

bool flagDebugThread = false;
late SharedPreferences prefs;
StreamController<String> theme = StreamController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Environment variable.
  ///
  /// Set it to [Env.dev] to use [MockThreadLoader] and [MockThreadRefresher].
  ///
  /// Don't forget to set it back to [Env.prod] before release build, otherwise
  /// an exception will be thrown.
  env = Env.prod;

  configureInjection(getIt, env);

  if (kReleaseMode && env != Env.prod) {
    throw Exception('Release mode can only be used with prod environment.');
  }

  if (kDebugMode && env == Env.prod) {
    debugPrint('Warning: running in debug mode with prod environment.');
  }

  prefs = await SharedPreferences.getInstance();
  await initializePreferences();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  await initLocalNotifications();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PageProvider provider = PageProvider(tabManager: TabManager());
    return StreamBuilder<String>(
      initialData: prefs.getString('theme'),
      stream: theme.stream,
      builder: (context, snapshot) {
        return ChangeNotifierProvider(
          create: (context) => provider,
          child: FGBGNotifier(
            onEvent: (value) {
              provider.tabManager.appLifeCycleStreamController.add(value);
            },
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: getTheme(snapshot.data!),
              home: const PageNavigator(),
              initialRoute: '/',
              onGenerateRoute: (settings) => getRoute(settings),
            ),
          ),
        );
      },
    );
  }
}
