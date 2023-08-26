import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/drawer/drawer.dart';
import '../../domain/models/tab.dart';

import '../provider/page_provider.dart';

/// Root widget of the app.
/// Controls pages, creates drawer and bottom navigation bar.
class PageNavigator extends StatefulWidget {
  const PageNavigator({super.key});
  @override
  State<PageNavigator> createState() => PageNavigatorState();
}

class PageNavigatorState extends State<PageNavigator>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final provider = context.read<PageProvider>();
    provider.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addTab(boardListTab);
      debugThread(provider);
    });
  }

  void debugThread(PageProvider provider) {
    if (kDebugMode && const String.fromEnvironment('thread') == 'true') {
      debugPrint('debugging thread');
      DrawerTab debugThreadTab = ThreadTab(
          name: "debug", tag: "b", prevTab: boardListTab, id: 282647314);
      provider.addTab(debugThreadTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PageProvider>(context, listen: true);

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
        key: provider.messengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          body: provider.currentPage,
          drawer: AppDrawer(provider: provider, scaffoldKey: _scaffoldKey),
          drawerEdgeDragWidth: 50,
          bottomNavigationBar: BottomBar(provider: provider),
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.provider,
  });
  final PageProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: BottomNavigationBar(
        selectedFontSize: 0.0,
        unselectedFontSize: 0.0,
        type: BottomNavigationBarType.fixed,
        currentIndex: provider.currentPageIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: ''), // or Icons.language
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: '')
        ],
        onTap: (value) {
          provider.setCurrentPageIndex(value, context: context);
        },
        backgroundColor: Theme.of(context).colorScheme.error,
        unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}

/// The widget that holds currently opened tab.
class BrowserScreen extends StatefulWidget {
  const BrowserScreen({
    super.key,
    required this.provider,
  });

  final PageProvider provider;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller:
          Provider.of<PageProvider>(context, listen: true).tabController,
      children: widget.provider.tabs.keys.map((tab) {
        switch (tab.runtimeType) {
          case BoardListTab:
            return widget.provider.getBoardListScreen(tab as BoardListTab);
          case BoardTab:
            return widget.provider.getBoardScreen(tab as BoardTab);
          case ThreadTab:
            return widget.provider.getThreadScreen(tab as ThreadTab);
          case BranchTab:
            return widget.provider.getBranchScreen(tab as BranchTab);
          default:
            throw Exception('Failed to get BlocProvider: no such tab type');
        }
      }).toList(),
    );
  }
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
void openDrawer() {
  _scaffoldKey.currentState!.openDrawer();
}

void closeDrawer() {
  _scaffoldKey.currentState!.closeDrawer();
}
