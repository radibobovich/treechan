import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/services/thread_service.dart';

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
    });
    prefs = await SharedPreferences.getInstance();
  });
  // IS NOT WORKING !!!!!!!!!!!! FIX IT !!!!!!!! please. i beg you. i need it. (c) copilot
  test('test', () async {
    final threadService = ThreadService(boardTag: 'pr', threadId: 1008826);

    await threadService.getRoots();
    final posts = threadService.getPosts;
    expect(posts, isNotNull);
    expect(posts, isNotEmpty);

    final threadInfo = threadService.getThreadInfo;
    expect(threadInfo.opPostId, posts![0].id);
    expect(threadInfo.postsCount, posts.length);
    expect(threadInfo.maxNum, posts[posts.length - 1].id);
  });
}

Future<void> initializePreferences() async {
  bool hasInitialized = prefs.getBool('initialized') ?? false;

  if (!hasInitialized) {
    // theme.add("Makaba Classic");
    await prefs.setBool('initialized', true);
  }

  if (prefs.getStringList('themes') == null) {
    await prefs.setStringList('themes', ['Makaba Night', 'Makaba Classic']);
  }
  if (prefs.getString('theme') == null) {
    await prefs.setString('theme', 'Makaba Classic');
  }
  if (prefs.getBool('postsCollapsed') == null) {
    await prefs.setBool('postsCollapsed', false);
  }
  if (prefs.getBool('2dscroll') == null) {
    await prefs.setBool('2dscroll', false);
  }
  if (prefs.getString('androidDestinationType') == null) {
    await prefs.setString('androidDestinationType', 'directoryDownloads');
  }

  return;
}
