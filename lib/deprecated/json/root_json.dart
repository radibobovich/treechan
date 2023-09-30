import "json.dart";

@Deprecated('Use models from models/core instead')
class Root {
  String? advertMobileImage;
  String? advertMobileLink;
  Board? board;
  String? boardBannerImage;
  String? boardBannerLink;
  String? filter;
  List<Thread>? threads;
  int? currentThread;
  int? filesCount;
  bool? isBoard;
  int? isClosed;
  bool? isIndex;
  int? maxNum;
  int? postsCount;
  String? threadFirstImage;
  String? title;
  int? uniquePosters;

  int? opPostId;
  bool? showLines;
  Root(
      {this.advertMobileImage,
      this.advertMobileLink,
      this.board,
      this.boardBannerImage,
      this.boardBannerLink,
      this.currentThread,
      this.filesCount,
      this.isBoard,
      this.isClosed,
      this.isIndex,
      this.maxNum,
      this.postsCount,
      this.threadFirstImage,
      this.title,
      this.uniquePosters,
      this.filter,
      this.threads,
      this.opPostId,
      this.showLines});

  Root.fromJson(Map<String, dynamic> json) {
    advertMobileImage = json['advert_mobile_image'];
    advertMobileLink = json['advert_mobile_link'];
    board = json['board'] != null ? Board.fromJson(json['board']) : null;
    boardBannerImage = json['board_banner_image'];
    boardBannerLink = json['board_banner_link'];
    filter = json['filter'];
    if (json['threads'] != null) {
      threads = <Thread>[];
      json['threads'].forEach((v) {
        threads!.add(Thread.fromJson(v));
      });
    }

    currentThread = json['current_thread'];
    filesCount = json['files_count'];
    isBoard = json['is_board'];
    isClosed = json['is_closed'];
    isIndex = json['is_index'];
    maxNum = json['max_num'];
    postsCount = json['posts_count'];
    threadFirstImage = json['thread_first_image'];
    title = json['title'];
    uniquePosters = json['unique_posters'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['advert_mobile_image'] = advertMobileImage;
    data['advert_mobile_link'] = advertMobileLink;
    if (board != null) {
      data['board'] = board!.toJson();
    }
    data['board_banner_image'] = boardBannerImage;
    data['board_banner_link'] = boardBannerLink;
    data['filter'] = filter;
    if (threads != null) {
      data['threads'] = threads!.map((v) => v.toJson()).toList();
    }

    data['current_thread'] = currentThread;
    data['files_count'] = filesCount;
    data['is_board'] = isBoard;
    data['is_closed'] = isClosed;
    data['is_index'] = isIndex;
    data['max_num'] = maxNum;
    data['posts_count'] = postsCount;
    data['thread_first_image'] = threadFirstImage;
    data['title'] = title;
    data['unique_posters'] = uniquePosters;

    return data;
  }
}
