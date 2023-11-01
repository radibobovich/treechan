// List<Board> boardListFromJson(List<dynamic> json) {
//   List<Board> boardList = List.empty(growable: true);
//   for (var boardItem in json) {
//     boardList.add(Board.fromJson(boardItem));
//   }
//   return boardList;
// }

// List<Post> postListFromJson(List<dynamic> json) {
//   List<Post> postList = List.empty(growable: true);
//   for (var postItem in json) {
//     postList.add(Post.fromJson(postItem));
//   }
//   return postList;
// }

import 'package:treechan/utils/constants/enums.dart';

import '../api/dvach/board_dvach_api_model.dart';
import 'thread.dart';

class Board {
  int bumpLimit;
  String category;
  String defaultName;
  // bool enableDices;
  // bool enableFlags;
  // bool enableIcons;
  // bool enableLikes;
  // bool enableNames;
  // bool enableOekaki;
  bool enablePosting;
  bool enableSage;
  // bool enableShield;
  // bool enableSubject;
  // bool enableThreadTags;
  // bool enableTrips;
  List<String> fileTypes;
  String id;
  String info;
  String infoOuter;
  int maxComment;
  int maxFilesSize;
  int maxPages;
  String name;
  int threadsPerPage;

  List<Thread> threads;
  //position in favorite list
  int? position;

  final Imageboard imageboard;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Board && id == other.id && name == other.name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return '$id $name';
  }

  Board({
    required this.bumpLimit,
    required this.category,
    required this.defaultName,
    // required this.enableDices,
    // required this.enableFlags,
    // required this.enableIcons,
    // required this.enableLikes,
    // required this.enableNames,
    // required this.enableOekaki,
    required this.enablePosting,
    required this.enableSage,
    // required this.enableShield,
    // required this.enableSubject,
    // required this.enableThreadTags,
    // required this.enableTrips,
    required this.fileTypes,
    required this.id,
    required this.info,
    required this.infoOuter,
    required this.maxComment,
    required this.maxFilesSize,
    required this.maxPages,
    required this.name,
    required this.threadsPerPage,
    required this.threads,
    this.position,
    required this.imageboard,
  });

  Board.fromResponseDvachApi(BoardResponseDvachApiModel boardResponse)
      : bumpLimit = boardResponse.board.bump_limit,
        category = boardResponse.board.category,
        defaultName = boardResponse.board.default_name!,
        // enableDices = board.enableDices,
        // enableFlags = board.enableFlags,
        // enableIcons = board.enableIcons,
        // enableLikes = board.enableLikes,
        // enableNames = board.enableNames,
        // enableOekaki = board.enableOekaki,
        enablePosting = boardResponse.board.enable_posting,
        enableSage = boardResponse.board.enable_sage,
        // enableShield = board.enableShield,
        // enableSubject = board.enableSubject,
        // enableThreadTags = board.enableThreadTags,
        // enableTrips = board.enableTrips,
        fileTypes = boardResponse.board.file_types,
        id = boardResponse.board.id,
        info = boardResponse.board.info,
        infoOuter = boardResponse.board.info_outer,
        maxComment = boardResponse.board.max_comment,
        maxFilesSize = boardResponse.board.max_files_size,
        maxPages = boardResponse.board.max_pages,
        name = boardResponse.board.name,
        threadsPerPage = boardResponse.board.threads_per_page,
        imageboard = Imageboard.dvach,
        threads = boardResponse.threads.map((thread) {
          if (boardResponse.pages != null) {
            return Thread.fromIndexBoardDvachApi(
                thread, boardResponse.board.id);
          } else {
            return Thread.fromCatalogBoardDvachApi(thread);
          }
        }).toList();

  Board.fromDvachApi(BoardDvachApiModel board)
      : bumpLimit = board.bump_limit,
        category = board.category,
        defaultName = board.default_name!,
        // enableDices = board.enableDices,
        // enableFlags = board.enableFlags,
        // enableIcons = board.enableIcons,
        // enableLikes = board.enableLikes,
        // enableNames = board.enableNames,
        // enableOekaki = board.enableOekaki,
        enablePosting = board.enable_posting,
        enableSage = board.enable_sage,
        // enableShield = board.enableShield,
        // enableSubject = board.enableSubject,
        // enableThreadTags = board.enableThreadTags,
        // enableTrips = board.enableTrips,
        fileTypes = board.file_types,
        id = board.id,
        info = board.info,
        infoOuter = board.info_outer,
        maxComment = board.max_comment,
        maxFilesSize = board.max_files_size,
        maxPages = board.max_pages,
        name = board.name,
        threadsPerPage = board.threads_per_page,
        imageboard = Imageboard.dvach,
        threads = [];

  Map<String, dynamic> toJson() {
    return {
      "bumpLimit": bumpLimit,
      "category": category,
      "defaultName": defaultName,
      // "enableDices": board.enableDices,
      // "enableFlags": board.enableFlags,
      // "enableIcons": board.enableIcons,
      // "enableLikes": board.enableLikes,
      // "enableNames": board.enableNames,
      // "enableOekaki": board.enableOekaki,
      "enablePosting": enablePosting,
      "enableSage": enableSage,
      // "enableShield": board.enableShield,
      // "enableSubject": board.enableSubject,
      // "enableThreadTags": board.enableThreadTags,
      // "enableTrips": board.enableTrips,
      "fileTypes": fileTypes,
      "id": id,
      "info": info,
      "infoOuter": infoOuter,
      "maxComment": maxComment,
      "maxFilesSize": maxFilesSize,
      "maxPages": maxPages,
      "name": name,
      "threadsPerPage": threadsPerPage,
      "threads": threads,
      "imageboard": imageboard.name,
    };
  }

  Board.fromJson(Map<String, dynamic> json)
      : bumpLimit = json['bumpLimit'],
        category = json['category'],
        defaultName = json['defaultName'],
        // enableDices = json['enableDices'],
        // enableFlags = json['enableFlags'],
        // enableIcons = json['enableIcons'],
        // enableLikes = json['enableLikes'],
        // enableNames = json['enableNames'],
        // enableOekaki = json['enableOekaki'],
        enablePosting = json['enablePosting'],
        enableSage = json['enableSage'],
        // enableShield = json['enableShield'],
        // enableSubject = json['enableSubject'],
        // enableThreadTags = json['enableThreadTags'],
        // enableTrips = json['enableTrips'],
        fileTypes = json['fileTypes'].cast<String>(),
        id = json['id'],
        info = json['info'],
        infoOuter = json['infoOuter'],
        maxComment = json['maxComment'],
        maxFilesSize = json['maxFilesSize'],
        maxPages = json['maxPages'],
        name = json['name'],
        threadsPerPage = json['threadsPerPage'],
        imageboard = imageboardFromString(json['imageboard']),
        threads = [];
}

/// function that converts Board to Map<String, dynamic>

/// function that converts List<Board> to Map<String, dynamic> for saving to shared preferences

Map<String, dynamic> boardListToJson(List<Board> boardList) {
  List<Map<String, dynamic>> boardListMap = List.empty(growable: true);
  for (var board in boardList) {
    boardListMap.add(board.toJson());
  }
  return {"boards": boardListMap};
}
