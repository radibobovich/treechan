import 'dart:async';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:treechan/data/thread/thread_loader.dart';
import 'package:treechan/data/thread/thread_refresher.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/repository_stream.dart';
import 'package:treechan/domain/models/tree.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/utils/constants/enums.dart';
import 'package:treechan/utils/count_a_tags.dart';
import 'package:treechan/utils/remove_html.dart';

// late SharedPreferences prefs;
void main() async {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'initialized': true,
      'themes': ['Makaba Night', 'Makaba Classic'],
      'theme': 'Makaba Classic',
      'postsCollapsed': false,
      '2dscroll': false,
      'androidDestinationType': 'directoryDownloads',
      'boardSortType': 'bump',
      'keepHistory': true,
      'trackerAutoRefresh': true,
      'refreshInterval': 60,
      'bottomDrawerTabs': false,
      'showSnackBarActionOnThreadRefresh': true,
      'getAllUpdates': false,
      'test': true
    });
    const env = Env.test;
    configureInjection(getIt, env);
  });

  tearDown(() {
    getIt.reset();
  });

  test('ThreadRepository', () async {
    final threadRepository = ThreadRepository(
      messenger: StreamController<RepositoryMessage>(),
      imageboard: Imageboard.dvach,
      boardTag: 'abu',
      threadId: 50074,

      /// it is a real thread so we dont mock loader and refresher
      threadLoader:
          ThreadRemoteLoader(imageboard: Imageboard.dvach, assetPath: ''),
      threadRefresher:
          ThreadRemoteRefresher(imageboard: Imageboard.dvach, assetPaths: ''),
    );

    List<TreeNode<Post>>? roots = await threadRepository.getRoots();
    final posts = threadRepository.posts;
    expect(posts, isNotEmpty, reason: 'Got empty posts list.');

    final threadInfo = threadRepository.threadInfo;
    expect(threadInfo.opPostId, posts.first.id,
        reason: "First post id doesn't match threadInfo OP id.");
    expect(threadInfo.maxNum, posts.last.id,
        reason: "Last post id doesn't match threadInfo maxNum property.");

    expect(roots, isNotEmpty, reason: 'Got empty roots list.');

    var post0 = Tree.findNode(roots, 50080);
    expect(post0, isNotNull,
        reason: 'Specified post 50080 not found in the tree.');
    expect(post0!.children.length >= 3, isTrue,
        reason: 'Specified post 50080 does not have enough children.');

    // 55509 answers to 55504 and 55506
    // check if tree matches these relationships
    TreeNode<Post>? post1 = Tree.findNode(roots, 55504);
    TreeNode<Post>? post2 = Tree.findNode(roots, 55506);
    expect(post1, isNotNull,
        reason: 'Specified parent 55504 not found in the tree.');
    expect(post2, isNotNull,
        reason: 'Specified parent 55506 not found in the tree.');

    expect(post1!.children.where((element) => element.data.id == 55509),
        isNotEmpty,
        reason: "Specified post 55504 doesn't have post 55509 as its child.");

    expect(post2!.children.where((element) => element.data.id == 55509),
        isNotEmpty,
        reason: "Specified post 55506 doesn't have post 55509 as its child.");
  });

  test('Thread refresh', () async {
    final threadRepository = ThreadRepository(
      messenger: StreamController<RepositoryMessage>(),
      imageboard: Imageboard.dvach,
      boardTag: 'b',
      threadId: 282647314,
      threadLoader: getIt.get<IThreadRemoteLoader>(
          param1: Imageboard.dvach, param2: 'assets/test/thread.json'),
      threadRefresher: getIt.get<IThreadRemoteRefresher>(
          param1: Imageboard.dvach, param2: ['assets/test/new_posts.json']),
    );

    List<TreeNode<Post>> roots = List.from(await threadRepository.getRoots());
    List<Post> posts = List.from(threadRepository.posts);

    await threadRepository.refresh();

    List<TreeNode<Post>> updatedRoots = await threadRepository.getRoots();
    List<Post> updatedPosts = threadRepository.posts;

    final threadInfo = threadRepository.threadInfo;
    expect(updatedPosts.last.id, threadInfo.maxNum,
        reason:
            "Last post id doesn't match threadInfo maxNum property after thread refresh.");

    // false if no updates in the thread.
    // but in this case should be always true
    expect(updatedPosts.length > posts.length, true,
        reason: "Post list length haven't changed after thread refresh.");

    // can be false if only replies were added
    // but in this case should be always true
    expect(updatedRoots.length > roots.length, true,
        reason: "Root nodes list length haven't changed after thread refresh.");

    expect(updatedPosts.last.isHighlighted, true,
        reason: "New post is not highlighted as a new.");
  });
  test('<a> tag count', () {
    String comment =
        '''<a href="/bo/res/843736.html#886558" class="post-reply-link" 
        data-thread="843736" data-num="886558">>>886558</a><br><a href="/bo/res/843736.html#886599" 
        class="post-reply-link" data-thread="843736" data-num="886599">>>886599</a><br>Cпасибо, 
        что еще можете посоветовать? Собираю список на все лето, т.к. уезжаю к бабке сраке в деревню 
        и буду без интернета 2 месяца''';
    int count = countATags(comment);
    expect(count, 2, reason: "Wrong count of reply post links.");
  });

  test('Remove html tags', () {
    const String htmlString =
        '<a href="/b/res/282647314.html#282647314" class="post-reply-link"'
        'data-thread="282647314" data-num="282647314">>>282647314 (OP)</a><br>'
        'А в чем он неправ? На работе надо максимально ловить проеб, считаешь по '
        'другому - гречневая пидораха.';
    final String cleanedString = removeHtmlTags(htmlString, links: false);
    expect(cleanedString,
        'А в чем он неправ? На работе надо максимально ловить проеб, считаешь по другому - гречневая пидораха.');
  });
  group('Search in tree', () {
    test('Search for one occurency', () async {
      final ThreadRepository repo = ThreadRepository(
        messenger: StreamController<RepositoryMessage>(),
        imageboard: Imageboard.dvach,
        boardTag: 'b',
        threadId: 282647314,
        threadLoader: getIt.get<IThreadRemoteLoader>(
            param1: Imageboard.dvach, param2: 'assets/test/thread.json'),
        threadRefresher: getIt.get<IThreadRemoteRefresher>(
            param1: Imageboard.dvach, param2: ['assets/test/new_posts.json']),
      );
      final List<TreeNode<Post>> roots = await repo.getRoots();
      TreeNode<Post>? result = Tree.findNode(roots, 282648865);
      expect(result, isNotNull, reason: 'No search results found.');
      expect(result!.parent!.data.id, 282648402,
          reason: '''Wrong parent id. Should be null because first
               occurence is a reply to OP.''');
    });
    test('Search for multiple occurencies', () async {
      final ThreadRepository repo = ThreadRepository(
          messenger: StreamController<RepositoryMessage>(),
          imageboard: Imageboard.dvach,
          boardTag: 'b',
          threadId: 282647314,
          threadLoader: getIt.get<IThreadRemoteLoader>(
              param1: Imageboard.dvach, param2: 'assets/test/thread.json'),
          threadRefresher: getIt.get<IThreadRemoteRefresher>(
              param1: Imageboard.dvach,
              param2: ['assets/test/new_posts.json']));
      final List<TreeNode<Post>> roots = await repo.getRoots();
      List<TreeNode<Post>> results = Tree.findAllNodes(roots, 282649012);
      expect(results.length, 2, reason: "Wrong search results count.");
      expect(results.first.parent!.data.id, 282647359,
          reason: "Wrong search result post id.");
      expect(results.last.parent!.data.id, 282648627,
          reason: "Wrong search result post id.");

      results = Tree.findAllNodes(roots, 282647874);
      expect(results.length, 2, reason: "Wrong search results count.");
      expect(results.first.parent!.data.id, 282647682,
          reason: "Wrong search result post id.");
      expect(results.last.parent?.data.id, null,
          reason: "Node was added as a child of OP-post what is wrong.");
    });
  });
}
