import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/config/themes.dart';

import '../../provider/page_provider.dart';
import '../../../domain/models/tab.dart';
import 'search_bar_widget.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.provider,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _scaffoldKey = scaffoldKey;

  final PageProvider provider;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SearchBar(
            // onOpen: (DrawerTab newTab) => provider.addTab(newTab),
            onCloseDrawer: () => _scaffoldKey.currentState!.closeDrawer(),
          ),
          const Divider(
            thickness: 1,
          ),
          TabsList(scaffoldKey: _scaffoldKey),
          const Divider(
            thickness: 1,
          ),
          HistoryButton(provider: provider),
          const SettingsButton(),
          SizedBox.fromSize(
            size: Size.fromHeight(MediaQuery.of(context).padding.bottom),
          )
          // history button
        ],
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.settings),
        title: const Text("Настройки"),
        textColor: Theme.of(context).textTheme.titleMedium!.color,
        iconColor: Theme.of(context).iconTheme.color,
        visualDensity: const VisualDensity(vertical: -2),
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        });
  }
}

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    super.key,
    required this.provider,
  });

  final PageProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.history),
        title: const Text("История"),
        textColor: Theme.of(context).textTheme.titleMedium!.color,
        iconColor: Theme.of(context).iconTheme.color,
        visualDensity: const VisualDensity(vertical: -4),
        onTap: () {
          Navigator.pushNamed(context, '/history', arguments: provider);
        });
  }
}

/// A list of opened tabs. Placed in the drawer.
class TabsList extends StatefulWidget {
  const TabsList({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<TabsList> createState() => _TabsListState();
}

class _TabsListState extends State<TabsList> {
  final prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    List<DrawerTab> tabs =
        context.watch<PageProvider>().tabManager.tabs.keys.toList();
    return FutureBuilder<SharedPreferences>(
        future: prefs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final bool reverseDrawerTabs =
              snapshot.data!.getBool('bottomDrawerTabs') ?? false;
          return Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                reverse: reverseDrawerTabs,
                itemCount: tabs.length,
                itemBuilder: (bcontext, index) {
                  final int actualIndex =
                      reverseDrawerTabs ? tabs.length - 1 - index : index;
                  DrawerTab item = tabs[actualIndex];
                  return TabTile(
                      // tabController: tabController,
                      item: item,
                      scaffoldKey: widget.scaffoldKey,
                      index: actualIndex);
                },
              ),
            ),
          );
        });
  }
}

class TabTile extends StatelessWidget {
  const TabTile({
    super.key,
    required this.item,
    required this.scaffoldKey,
    required this.index,
  });

  final DrawerTab item;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int index;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: context.watch<PageProvider>().tabManager.currentIndex == index,
      textColor: Theme.of(context).textTheme.titleMedium!.color,
      selectedColor: context.colors.boldText,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
      title: Text(
        (item is BoardTab
                ? "/${(item as BoardTab).tag}/ - "
                : (item is TagMixin ? "/${(item as TagMixin).tag}/ - " : "")) +
            (item.name ?? (item is BoardTab ? "Доска" : "Тред")),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: item is IdMixin
            ? null
            : const TextStyle(fontWeight: FontWeight.w900),
      ),
      trailing: item is! BoardListTab
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<PageProvider>().removeTab(item);
              },
              color: Theme.of(context).textTheme.titleMedium!.color,
            )
          : const SizedBox.shrink(),
      onTap: () {
        context.read<PageProvider>().tabManager.animateTo(index);
        scaffoldKey.currentState!.closeDrawer();
      },
    );
  }
}
