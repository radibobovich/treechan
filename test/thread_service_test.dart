import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/models/json/json.dart';
import 'package:treechan/domain/models/tree.dart';
import 'package:treechan/domain/services/thread_service.dart';
import 'package:treechan/presentation/widgets/shared/html_container_widget.dart';
import 'package:treechan/utils/remove_html.dart';

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
      'test': true
    });
  });
  test('ThreadService', () async {
    final threadService = ThreadService(boardTag: 'abu', threadId: 50074);

    List<TreeNode<Post>>? roots = await threadService.getRoots();
    final posts = threadService.getPosts;
    expect(posts, isNotEmpty, reason: 'Got empty posts list.');

    final threadInfo = threadService.getThreadInfo;
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
    // using pre-downloaded thread from /assets folder
    // thread fetcher uses it instead of fetching from the internet because of
    // shared preferences 'test' flag
    final threadService = ThreadService(boardTag: 'b', threadId: 282647314);

    List<TreeNode<Post>> roots = List.from(await threadService.getRoots());
    List<Post> posts = List.from(threadService.getPosts);

    await threadService.refresh();

    List<TreeNode<Post>> updatedRoots = await threadService.getRoots();
    List<Post> updatedPosts = threadService.getPosts;

    final threadInfo = threadService.getThreadInfo;
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
        '<a href="/bo/res/843736.html#886558" class="post-reply-link" data-thread="843736" data-num="886558">>>886558</a><br><a href="/bo/res/843736.html#886599" class="post-reply-link" data-thread="843736" data-num="886599">>>886599</a><br>Cпасибо, что еще можете посоветовать? Собираю список на все лето, т.к. уезжаю к бабке сраке в деревню и буду без интернета 2 месяца';
    int count = countATags(comment);
    expect(count, 2, reason: "Wrong count of reply post links.");
  });

  test('Remove html tags', () {
    String htmlString =
        '<a href="/b/res/282647314.html#282647314" class="post-reply-link" data-thread="282647314" data-num="282647314">>>282647314 (OP)</a><br>А в чем он неправ? На работе надо максимально ловить проеб, считаешь по другому - гречневая пидораха.';
    String cleanedString = removeHtmlTags(htmlString, links: false);
    expect(cleanedString,
        'А в чем он неправ? На работе надо максимально ловить проеб, считаешь по другому - гречневая пидораха.');
  });
}
