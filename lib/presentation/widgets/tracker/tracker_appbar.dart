import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/tracker_cubit.dart';
import 'popup_menu_tracker.dart';

class TrackerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TrackerAppBar({
    super.key,
    required this.appBar,
  });
  final AppBar appBar;

  @override
  State<TrackerAppBar> createState() => _TrackerAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}

class _TrackerAppBarState extends State<TrackerAppBar> {
  late final Future<bool> autoRefreshStatus;
  @override
  void didChangeDependencies() {
    // autoRefreshStatus = context.read<TrackerCubit>().getAutoRefreshStatus();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Трекер"),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<TrackerCubit>().refreshAll();
          },
        ),
        FutureBuilder<bool>(
          future: context.read<TrackerCubit>().getAutoRefreshStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return IconButton(
                icon: snapshot.data as bool
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                onPressed: () async {
                  await context.read<TrackerCubit>().toggleAutoRefresh();
                  setState(() {});
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const PopupMenuTracker()
      ],
    );
  }
}
