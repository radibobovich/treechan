import 'package:flutter_test/flutter_test.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/utils/constants/enums.dart';

void main() {
  test('Dvach normal thread link test', () {
    const String url = 'https://2ch.hk/bo/res/924270.html#bottom';
    final DrawerTab newTab =
        ImageboardSpecific.tryOpenUnknownTabFromLink(url, null);

    final DrawerTab expectedTab = ThreadTab(
      imageboard: Imageboard.dvach,
      id: 924270,
      tag: 'bo',
      prevTab: boardListTab,
      name: null,
    );

    expect(newTab, expectedTab, reason: 'newTab does not match expectedTab');
  });

  test('Dvach normal board link test', () {
    const String url = 'https://2ch.hk/abu/';
    final DrawerTab newTab =
        ImageboardSpecific.tryOpenUnknownTabFromLink(url, null);

    final DrawerTab expectedTab = BoardTab(
        imageboard: Imageboard.dvach, tag: 'abu', prevTab: boardListTab);

    expect(newTab, expectedTab, reason: 'newTab does not match expectedTab');
  });

  test('Dvach catalog board link test', () {
    const String url = 'https://2ch.hk/pr/catalog.html';
    final DrawerTab newTab = ImageboardSpecific.tryOpenUnknownTabFromLink(
        url, null,
        searchTag: 'android');

    final DrawerTab expectedTab = BoardTab(
      imageboard: Imageboard.dvach,
      tag: 'pr',
      isCatalog: true,
      query: 'android',
      prevTab: boardListTab,
    );
    expect(newTab.runtimeType, BoardTab,
        reason: 'Wrong tab type: ${newTab.runtimeType}');
    expect(newTab, expectedTab, reason: 'newTab does not match expectedTab');
    expect((newTab as BoardTab).isCatalog, true, reason: 'Is not catalog');
    expect(newTab.query, 'android', reason: 'Wrong search query');
  });

  test('Dvach arhived thread link test', () {
    const String url = 'https://2ch.hk/a/arch/2016-02-13/res/2656447.json';
    final DrawerTab newTab =
        ImageboardSpecific.tryOpenUnknownTabFromLink(url, null);

    final DrawerTab expectedTab = ThreadTab(
      imageboard: Imageboard.dvachArchive,
      id: 2656447,
      tag: 'a',
      name: null,
      prevTab: boardListTab,
    );

    expect(newTab, expectedTab);
  });

  test('Board tag search scenario test', () {
    const String searchQuery = 'b';
    final DrawerTab newTab =
        ImageboardSpecific.tryOpenUnknownTabFromLink(searchQuery, boardListTab);
    final DrawerTab expectedTab =
        BoardTab(imageboard: Imageboard.dvach, tag: 'b', prevTab: boardListTab);

    expect(newTab, expectedTab);
  });

  test('Board tag + id search scenario test', () {
    const String searchQuery = 'a/7633107';
    final DrawerTab newTab =
        ImageboardSpecific.tryOpenUnknownTabFromLink(searchQuery, boardListTab);
    final DrawerTab expectedTab = ThreadTab(
      name: null,
      imageboard: Imageboard.dvach,
      tag: 'a',
      prevTab: boardListTab,
      id: 7633107,
    );
    expect(newTab, expectedTab);
  });
}
