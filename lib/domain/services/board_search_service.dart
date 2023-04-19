import '../models/json/json.dart';

class BoardSearchService {
  BoardSearchService({required this.threads});
  final List<Thread> threads;

  Future<List<Thread>> search(String query) async {
    if (query.isEmpty) {
      return threads;
    }
    return threads.where((thread) {
      final post = thread.posts[0];
      return post.comment!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
