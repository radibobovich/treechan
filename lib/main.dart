import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/router.dart';
import 'config/preferences.dart';
import 'presentation/provider/page_provider.dart';
import 'presentation/screens/page_navigator.dart';

bool flagDebugThread = false;
late SharedPreferences prefs;
StreamController<String> theme = StreamController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await initializePreferences();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      initialData: prefs.getString('theme'),
      stream: theme.stream,
      builder: (context, snapshot) {
        return ChangeNotifierProvider(
          create: (context) => PageProvider(),
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: getTheme(snapshot.data!),
            home: const PageNavigator(),
            initialRoute: '/',
            onGenerateRoute: (settings) => getRoute(settings),
          ),
        );
      },
    );
  }
}
