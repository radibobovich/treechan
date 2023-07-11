import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/models/json/json.dart';
import 'package:treechan/domain/models/tree.dart';
import 'package:treechan/domain/services/thread_service.dart';

late SharedPreferences prefs;
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
    });
  });
  test('ThreadService', () async {
    final threadService = ThreadService(boardTag: 'abu', threadId: 50074);

    List<TreeNode<Post>>? roots = await threadService.getRoots();
    final posts = threadService.getPosts;
    expect(posts, isNotNull);
    expect(posts, isNotEmpty);

    final threadInfo = threadService.getThreadInfo;
    expect(threadInfo.opPostId, posts![0].id);
    expect(threadInfo.maxNum, posts[posts.length - 1].id);

    expect(roots!, isNotEmpty);

    var post0 = Tree.findPost(roots, 50080);
    expect(post0, isNotNull);
    expect(post0!.children.length >= 3, isTrue);

    // 55509 answers to 55504 and 55506
    // check if tree matches these relationships
    TreeNode<Post>? post1 = Tree.findPost(roots, 55504);
    TreeNode<Post>? post2 = Tree.findPost(roots, 55506);
    expect(post1, isNotNull);
    expect(post2, isNotNull);

    expect(post1!.children.where((element) => element.data.id == 55509),
        isNotEmpty);

    expect(post2!.children.where((element) => element.data.id == 55509),
        isNotEmpty);
  });
}
