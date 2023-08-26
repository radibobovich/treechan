import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain/models/tab.dart';
import 'presentation/bloc/history_bloc.dart';
import 'presentation/provider/page_provider.dart';
import 'presentation/screens/hidden_posts_screen.dart';
import 'presentation/screens/hidden_threads_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/page_navigator.dart';
import 'presentation/screens/settings_screen.dart';

Route<dynamic> getRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/history':
      return MaterialPageRoute(
          builder: (context) => BlocProvider(
                create: (context) => HistoryBloc()..add(LoadHistoryEvent()),
                child: HistoryScreen(onOpen: (DrawerTab newTab) {
                  (settings.arguments as PageProvider).addTab(newTab);
                  closeDrawer();
                }),
              ));
    case '/settings':
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case '/hidden_threads':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) => HiddenThreadsScreen(
              currentTab: args['currentTab'], onOpen: args['onOpen']));
    case '/hidden_posts':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) =>
              HiddenPostsScreen(tag: args['tag'], threadId: args['threadId']));
    default:
      return MaterialPageRoute(builder: (_) => const PageNavigator());
  }
}
