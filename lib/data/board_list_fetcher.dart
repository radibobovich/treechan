import 'package:http/http.dart' as http;

class BoardListFetcher {
  static Future<String?> getBoardListResponse() async {
    String url = "https://2ch.hk/api/mobile/v2/boards";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load board list. Error code: ${response.statusCode}');
    }
  }
}
