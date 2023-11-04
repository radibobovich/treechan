import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hidable/hidable.dart';
import 'package:provider/provider.dart';
import 'package:treechan/utils/constants/constants.dart';
import 'package:treechan/utils/custom_hidable_visibility.dart';

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
  Orientation? prevOrientation;
  @override
  void initState() {
    super.initState();
    final provider = context.read<PageProvider>();
    provider.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addTab(boardListTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PageProvider>(context, listen: true);

    /// Overrides Android back button to go back to the previous tab.
    return WillPopScope(
      onWillPop: () async {
        int currentIndex = provider.tabManager.currentIndex;
        if (currentIndex > 0) {
          provider.goBack();
          return Future.value(false);
        } else {
          if (provider.currentPageIndex == 0) {
            provider.setCurrentPageIndex(2);
          }
          return Future.value(true);
        }
      },
      child: ScaffoldMessenger(
        key: provider.messengerKey,
        child: OrientationBuilder(builder: (context, orientation) {
          prevOrientation ??= orientation;
          if (prevOrientation != orientation) {
            if (orientation == Orientation.portrait) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            } else {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
            }
          }
          return Scaffold(
            key: _scaffoldKey,

            /// Holds pages ([TrackerScreen] and [BrowserScreen])
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: provider.pageController,
                children: provider.pages),
            drawer: AppDrawer(provider: provider, scaffoldKey: _scaffoldKey),
            drawerEdgeDragWidth: 50,
            bottomNavigationBar: BottomBar(provider: provider),
          );
        }),
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
    final systemBarHeight = MediaQuery.of(context).padding.bottom;
    return Hidable(
      controller: provider.tabManager.tabScrollControllerReference,
      visibility: customHidableVisibility,
      deltaFactor: 0.04,
      preferredWidgetSize:
          Size.fromHeight(AppConstants.navBarHeight + systemBarHeight),
      child: SizedBox(
        height: AppConstants.navBarHeight,
        child: BottomNavigationBar(
          selectedFontSize: 0.0,
          unselectedFontSize: 0.0,
          enableFeedback: false,
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
        ),
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

    /// Holds tabs ([BoardListTab], [BoardTab], [ThreadTab], [BranchTab]).
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: Provider.of<PageProvider>(context, listen: true)
          .tabManager
          .tabController,
      children: widget.provider.tabManager.tabs.keys.map((tab) {
        switch (tab.runtimeType) {
          case BoardListTab:
            return widget.provider.tabManager
                .getBoardListScreen(tab as BoardListTab);
          case BoardTab:
            return widget.provider.tabManager.getBoardScreen(tab as BoardTab);
          case ThreadTab:
            return widget.provider.tabManager.getThreadScreen(tab as ThreadTab);
          case BranchTab:
            return widget.provider.tabManager.getBranchScreen(tab as BranchTab);
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
