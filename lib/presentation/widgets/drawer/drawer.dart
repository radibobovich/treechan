import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/history_bloc.dart';
import '../../provider/page_provider.dart';
import '../../../domain/models/tab.dart';
import '../../screens/history_screen.dart';
import '../../screens/settings_screen.dart';
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
          HistoryButton(provider: provider, scaffoldKey: _scaffoldKey),
          const SettingsButton(),
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
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()));
        });
  }
}

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    super.key,
    required this.provider,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _scaffoldKey = scaffoldKey;

  final PageProvider provider;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.history),
        title: const Text("История"),
        textColor: Theme.of(context).textTheme.titleMedium!.color,
        iconColor: Theme.of(context).iconTheme.color,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BlocProvider(
                        create: (context) =>
                            HistoryBloc()..add(LoadHistoryEvent()),
                        child: HistoryScreen(onOpen: (DrawerTab newTab) {
                          provider.addTab(newTab);
                          _scaffoldKey.currentState!.closeDrawer();
                        }),
                      )));
        });
  }
}

/// A list of opened tabs. Placed in the drawer.
class TabsList extends StatelessWidget {
  const TabsList({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    List<DrawerTab> tabs = context.watch<PageProvider>().tabs.keys.toList();
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: tabs.length,
          itemBuilder: (bcontext, index) {
            DrawerTab item = tabs[index];
            return TabTile(
                // tabController: tabController,
                item: item,
                scaffoldKey: scaffoldKey,
                index: index);
          },
        ),
      ),
    );
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
      selected: context.watch<PageProvider>().currentIndex == index,
      textColor: Theme.of(context).textTheme.titleMedium!.color,
      selectedColor: Theme.of(context).secondaryHeaderColor,
      title: Row(
        children: [
          Expanded(
            child: Text(
              (item is BoardTab ? "/${item.tag}/ - " : "") +
                  (item.name ?? (item is BoardTab ? "Доска" : "Тред")),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          item is! BoardListTab
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<PageProvider>().removeTab(item);
                  },
                  color: Theme.of(context).textTheme.titleMedium!.color,
                )
              : const SizedBox.shrink()
        ],
      ),
      onTap: () {
        context.read<PageProvider>().animateTo(index);
        scaffoldKey.currentState!.closeDrawer();
      },
    );
  }
}
