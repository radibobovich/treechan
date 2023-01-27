import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/board_json.dart';
import 'dart:convert';

Future<List<Board>?> getBoards() async {
  SharedPreferences prefs;
  prefs = await SharedPreferences.getInstance();
  prefs.clear();
  String? boards = prefs.getString('boards');

  if (boards != null) {
    List<Board> boardList = boardListFromJson(jsonDecode(boards))!;
    return boardList;
  }
  String? downloadedBoards = await downloadBoards();
  if (downloadedBoards == null) {
    return List.empty();
    // means that you have to ask user to check internet
  }
  prefs.setString('boards', downloadedBoards);
  return boardListFromJson(jsonDecode(downloadedBoards));
}

Future<String?> downloadBoards() async {
  var url = "https://2ch.hk/api/mobile/v2/boards";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    //var boardList = BoardList.fromJson(jsonDecode(response.body));
    return response.body;
    //prefs.setString('boards', response.body);
    //return boardListFromJson(jsonDecode(response.body));
  }
  return null;
}
