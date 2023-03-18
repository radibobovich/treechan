import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/themes.dart';
import 'models/thread_bloc.dart';
import 'screens/tab_navigator.dart';
import 'deprecated/test.dart';
import 'services/thread_service.dart';

bool flagDebugThread = false;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.nightTheme,
      home: const TabNavigator(),
      // home: const TestList(),
      initialRoute: '/',
    );
  }
}
