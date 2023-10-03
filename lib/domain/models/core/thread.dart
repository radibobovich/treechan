import 'package:treechan/domain/models/api/dvach/thread_dvach_api_model.dart';

import 'post.dart';

class Thread {
  final int id;
  final String boardTag;
  final int filesCount;
  final List<Post> posts;
  final int postsCount;

  bool hidden = false;
  Thread({
    required this.id,
    required this.boardTag,
    required this.filesCount,
    required this.posts,
    required this.postsCount,
  });

  Thread.fromIndexBoardDvachApi(ThreadDvachApiModel thread, this.boardTag)
      : id = thread.thread_num ?? -1,
        filesCount = thread.files_count ?? -1,
        posts = thread.posts!.map((post) => Post.fromDvachApi(post)).toList(),
        postsCount = thread.posts_count ?? 0;

  Thread.fromCatalogBoardDvachApi(ThreadDvachApiModel thread)
      : id = thread.num ?? -1,
        boardTag = thread.board ?? '',
        filesCount = thread.files_count ?? -1,
        posts = [Post.fromCatalogBoardDvachApi(thread)],
        postsCount = thread.posts_count ?? 0;

  Thread.fromThreadDvachApi(ThreadResponseDvachApiModel threadResponse)
      : id = threadResponse.current_thread,
        boardTag = threadResponse.board.id,
        filesCount = threadResponse.files_count,
        posts = threadResponse.threads.first.posts!
            .map((post) => Post.fromDvachApi(post))
            .toList(),
        postsCount = threadResponse.posts_count;
}
