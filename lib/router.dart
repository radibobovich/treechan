import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/presentation/bloc/filters_cubit.dart';
import 'package:treechan/presentation/screens/filter/filter_edit_screen.dart';
import 'package:treechan/presentation/screens/filter/filters_screen.dart';

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
    case '/filters':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) => BlocProvider(
                create: (context) => FiltersCubit(
                  displayMode: args['displayMode'],
                  imageboard: args['imageboard'],
                  boardTag: args['boardTag'],
                )..init(),
                child: const FiltersScreen(),
              ));
    case '/filter_edit':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) => FilterEditScreen(
                filter: args['filter'],
                add: args['add'],
                update: args['update'],
                getBoards: args['getBoards'],
                currentBoard: args['currentBoard'],
              ));
    default:
      return MaterialPageRoute(builder: (_) => const PageNavigator());
  }
}
