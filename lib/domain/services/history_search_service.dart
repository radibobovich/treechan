import '../models/tab.dart';

class HistorySearchService {
  HistorySearchService({required this.history}) {
    // history.then((value) => _historyList.addAll(value));
  }
  final List<HistoryTab> history;
  // final List<HistoryTab> _historyList = [];

  Future<List<HistoryTab>> search(String query) async {
    if (query.isEmpty) {
      return history;
    }
    return history
        .where((element) =>
            (element.name!.toLowerCase().contains(query.toLowerCase()) ||
                element.tag.toLowerCase().contains(query.toLowerCase()) ||
                element.id.toString().contains(query)))
        .toList();
  }
}
