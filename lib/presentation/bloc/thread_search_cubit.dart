import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';

class ThreadSearchCubit extends Cubit<ThreadSearchState> {
  ThreadSearchCubit({
    required this.tab,
    this.threadBloc,
  }) : super(ThreadSearchInitial());
  IdMixin? tab;
  ThreadBloc? threadBloc;
  final TextEditingController controller = TextEditingController();

  void configure(IdMixin tab, ThreadBloc bloc) {
    controller.text = '';
    this.tab = tab;
    threadBloc = bloc;
  }

  void searchQueryChanged(String query) async {
    assert(threadBloc != null, 'You should pass bloc to search in the thread');
    if (threadBloc == null) return;

    final Map<int, List<TreeNode<Post>>> plainNodes =
        threadBloc!.threadRepository.plainNodes;

    final List<TreeNode<Post>> results = plainNodes.values
        .where((list) =>
            list.first.data.comment.toLowerCase().contains(query.toLowerCase()))
        .map((list) => list.first)
        .toList();
    emit(ThreadSearchLoaded(nodes: results));
  }
}

abstract class ThreadSearchState {}

class ThreadSearchInitial extends ThreadSearchState {}

class ThreadSearchLoaded extends ThreadSearchState {
  ThreadSearchLoaded({required this.nodes});
  final List<TreeNode<Post>> nodes;
}
