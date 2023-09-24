import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/tracked_item.dart';

import '../bloc/tracker_cubit.dart';
import '../widgets/tracker/tracker_appbar.dart';
import '../widgets/tracker/tracker_lists.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TrackerAppBar(appBar: AppBar()),
        body: BlocBuilder<TrackerCubit, TrackerState>(
          builder: (context, state) {
            if (state is TrackerLoadedState) {
              return TrackerBuilder(
                  threads: state.threads, branches: state.branches);
            } else if (state is TrackerRefreshingState) {
              return TrackerBuilder(
                threads: state.threads,
                branches: state.branches,
                refreshingItem: state.refreshingItem,
              );
            } else if (state is TrackerErrorState) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class TrackerBuilder extends StatelessWidget {
  final List<TrackedThread> threads;
  final List<TrackedBranch> branches;
  final TrackedItem? refreshingItem;
  const TrackerBuilder(
      {super.key,
      required this.threads,
      required this.branches,
      this.refreshingItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Text('Треды',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.boldText)),
            ),
            ThreadsList(
              threads: threads,
              refreshingItem: refreshingItem,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Text('Ветки',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.boldText)),
            ),
            BranchesList(
              branches: branches,
              refreshingItem: refreshingItem,
            )
          ],
        ),
      ),
    );
  }
}
