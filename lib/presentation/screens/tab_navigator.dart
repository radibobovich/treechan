import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/enums.dart';

import '../widgets/drawer/drawer.dart';
import '../../domain/models/tab.dart';

import '../provider/tab_provider.dart';

/// Root widget of the app.
/// Controls tabs and creates a drawer with tabs.
class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key});
  @override
  State<TabNavigator> createState() => TabNavigatorState();
}

class TabNavigatorState extends State<TabNavigator>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    final provider = context.read<TabProvider>();
    provider.initController(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addTab(boardListTab);
      debugThread(provider);
    });
  }

  void debugThread(TabProvider provider) {
    if (kDebugMode && const String.fromEnvironment('thread') == 'true') {
      debugPrint('debugging thread');
      DrawerTab debugThreadTab = ThreadTab(
          name: "debug", tag: "b", prevTab: boardListTab, id: 282647314);
      provider.addTab(debugThreadTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TabProvider>(context, listen: true);

    /// Overrides Android back button to go back to the previous tab.
    return WillPopScope(
      onWillPop: () async {
        int currentIndex = provider.currentIndex;
        if (currentIndex > 0) {
          provider.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: ScaffoldMessenger(
        child: Scaffold(
          key: _scaffoldKey,
          body: Screen(provider: provider),
          drawer: AppDrawer(provider: provider, scaffoldKey: _scaffoldKey),
        ),
      ),
    );
  }
}

/// The widget showing current tab.
class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.provider,
  });

  final TabProvider provider;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller:
          Provider.of<TabProvider>(context, listen: false).tabController,
      children: provider.tabs.keys.map((tab) {
        switch (tab.runtimeType) {
          case BoardListTab:
            return provider.getBoardListScreen(tab);
          case BoardTab:
            return provider.getBoardScreen(tab);
          case ThreadTab:
            return provider.getThreadScreen(tab);
          case BranchTab:
            return provider.getBranchScreen(tab);
          default:
            throw Exception('Failed to get BlocProvider: no such tab type');
        }
      }).toList(),
    );
  }
}
