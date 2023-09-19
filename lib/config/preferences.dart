import '../main.dart';

Future<void> initializePreferences() async {
  bool hasInitialized = prefs.getBool('initialized') ?? false;

  if (!hasInitialized) {
    theme.add("Makaba Classic");
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
  if (prefs.getString('boardSortType') == null) {
    await prefs.setString('boardSortType', 'bump');
  }
  if (prefs.getBool('spoilers') == null) {
    await prefs.setBool('spoilers', true);
  }
  if (prefs.getBool('trackerAutoRefresh') == null) {
    await prefs.setBool('trackerAutoRefresh', true);
  }
  if (prefs.getInt('refreshInterval') == null) {
    await prefs.setInt('refreshInterval', 60);
  }
  return;
}
