import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/presentation/bloc/thread_search_cubit.dart';
import 'package:treechan/presentation/widgets/thread/post_widget.dart';

class ThreadSearchScreen extends StatelessWidget {
  const ThreadSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56), child: SearchAppBar()),
      body: BlocBuilder<ThreadSearchCubit, ThreadSearchState>(
        builder: (context, state) {
          if (state is ThreadSearchLoaded) {
            final nodes = state.nodes;
            final threadBloc = context.read<ThreadSearchCubit>().threadBloc!;
            return ListView.builder(
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                return PostWidget(
                  key: ObjectKey(nodes[index].data),
                  bloc: threadBloc,
                  node: nodes[index],
                  roots: threadBloc.threadRepository.getRootsSynchronously,
                  currentTab: threadBloc.tab as ThreadTab,
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: context.read<ThreadSearchCubit>().controller,
        autofocus: true,
        decoration: const InputDecoration(
            hintText: ' Поиск',
            hintStyle: TextStyle(color: Colors.white70),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white))),
        onChanged: (query) {
          context.read<ThreadSearchCubit>().searchQueryChanged(query);
        },
      ),
    );
  }
}
