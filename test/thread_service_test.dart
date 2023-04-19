import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final threadService = ThreadService(boardTag: 'pr', threadId: 1008826);

    await threadService.getRoots();
    final posts = threadService.getPosts;
    expect(posts, isNotNull);
    expect(posts, isNotEmpty);

    final threadInfo = threadService.getThreadInfo;
    expect(threadInfo.opPostId, posts![0].id);
    expect(threadInfo.maxNum, posts[posts.length - 1].id);
  });
}
