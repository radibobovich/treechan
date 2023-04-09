import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/themes.dart';
import 'screens/tab_navigator.dart';

bool flagDebugThread = false;
late SharedPreferences prefs;
StreamController<String> theme = StreamController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await initializePreferences();
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
        return MaterialApp(
          title: 'Flutter Demo',
          theme: getTheme(snapshot.data!),
          home: const TabNavigator(),
          initialRoute: '/',
        );
      },
    );
  }
}

Future<void> initializePreferences() async {
  bool hasInitialized = prefs.getBool('initialized') ?? false;

  if (!hasInitialized) {
    theme.add("Makaba Classic");
    await prefs.setBool('initialized', true);
  }

  if (prefs.getStringList('themes') == null) {
    await prefs.setStringList('themes', ['Makaba Night', 'Makaba Classic']);
  }
  if (prefs.getString('theme') == null) {
    await prefs.setString('theme', 'Makaba Classic');
  }
  if (prefs.getBool('postsCollapsed') == null) {
    await prefs.setBool('postsCollapsed', false);
  }
  if (prefs.getBool('2dscroll') == null) {
    await prefs.setBool('2dscroll', false);
  }

  return;
}

ThemeData getTheme(String theme) {
  switch (theme) {
    case 'Makaba Night':
      return AppTheme.makabaNight;
    case 'Makaba Classic':
      return AppTheme.makabaClassic;
  }
  return AppTheme.makabaClassic;
}
