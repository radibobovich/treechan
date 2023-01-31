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
      this.threads});

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

List<Board>? boardListFromJson(List<dynamic> json) {
  List<Board>? boardList = List.empty(growable: true);
  for (var boardItem in json) {
    boardList.add(Board.fromJson(boardItem));
  }
  return boardList;
}
// class BoardListContainer {
//   List<Board>? boardList = List.empty(growable: true);
//   BoardListContainer({this.boardList});
//   BoardListContainer.fromJson(List<dynamic> json) {
//     for (var boardItem in json) {
//       boardList!.add(Board.fromJson(boardItem));
//     }
//   }
// }

class Board {
  int? bumpLimit;
  String? category;
  String? defaultName;
  bool? enableDices;
  bool? enableFlags;
  bool? enableIcons;
  bool? enableLikes;
  bool? enableNames;
  bool? enableOekaki;
  bool? enablePosting;
  bool? enableSage;
  bool? enableShield;
  bool? enableSubject;
  bool? enableThreadTags;
  bool? enableTrips;
  List<String>? fileTypes;
  String? id;
  String? info;
  String? infoOuter;
  int? maxComment;
  int? maxFilesSize;
  int? maxPages;
  String? name;
  int? threadsPerPage;

  Board(
      {this.bumpLimit,
      this.category,
      this.defaultName,
      this.enableDices,
      this.enableFlags,
      this.enableIcons,
      this.enableLikes,
      this.enableNames,
      this.enableOekaki,
      this.enablePosting,
      this.enableSage,
      this.enableShield,
      this.enableSubject,
      this.enableThreadTags,
      this.enableTrips,
      this.fileTypes,
      this.id,
      this.info,
      this.infoOuter,
      this.maxComment,
      this.maxFilesSize,
      this.maxPages,
      this.name,
      this.threadsPerPage});

  Board.fromJson(Map<String, dynamic> json) {
    bumpLimit = json['bump_limit'];
    category = json['category'];
    defaultName = json['default_name'];
    enableDices = json['enable_dices'];
    enableFlags = json['enable_flags'];
    enableIcons = json['enable_icons'];
    enableLikes = json['enable_likes'];
    enableNames = json['enable_names'];
    enableOekaki = json['enable_oekaki'];
    enablePosting = json['enable_posting'];
    enableSage = json['enable_sage'];
    enableShield = json['enable_shield'];
    enableSubject = json['enable_subject'];
    enableThreadTags = json['enable_thread_tags'];
    enableTrips = json['enable_trips'];
    fileTypes = json['file_types'].cast<String>();
    id = json['id'];
    info = json['info'];
    infoOuter = json['info_outer'];
    maxComment = json['max_comment'];
    maxFilesSize = json['max_files_size'];
    maxPages = json['max_pages'];
    name = json['name'];
    threadsPerPage = json['threads_per_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bump_limit'] = bumpLimit;
    data['category'] = category;
    data['default_name'] = defaultName;
    data['enable_dices'] = enableDices;
    data['enable_flags'] = enableFlags;
    data['enable_icons'] = enableIcons;
    data['enable_likes'] = enableLikes;
    data['enable_names'] = enableNames;
    data['enable_oekaki'] = enableOekaki;
    data['enable_posting'] = enablePosting;
    data['enable_sage'] = enableSage;
    data['enable_shield'] = enableShield;
    data['enable_subject'] = enableSubject;
    data['enable_thread_tags'] = enableThreadTags;
    data['enable_trips'] = enableTrips;
    data['file_types'] = fileTypes;
    data['id'] = id;
    data['info'] = info;
    data['info_outer'] = infoOuter;
    data['max_comment'] = maxComment;
    data['max_files_size'] = maxFilesSize;
    data['max_pages'] = maxPages;
    data['name'] = name;
    data['threads_per_page'] = threadsPerPage;
    return data;
  }
}

class Thread {
  int? banned;
  String? board;
  int? closed;
  String? comment;
  String? date;
  String? email;
  int? endless;
  List<File>? files;
  int? filesCount;
  int? lasthit;
  String? name;
  int? num_;
  int? op;
  int? parent;
  int? postsCount;
  int? sticky;
  String? subject;
  String? tags;
  int? timestamp;
  String? trip;
  int? views;
  List<Post>? posts;

  Thread(
      {this.banned,
      this.board,
      this.closed,
      this.comment,
      this.date,
      this.email,
      this.endless,
      this.files,
      this.filesCount,
      this.lasthit,
      this.name,
      this.num_,
      this.op,
      this.parent,
      this.postsCount,
      this.sticky,
      this.subject,
      this.tags,
      this.timestamp,
      this.trip,
      this.views,
      this.posts});

  Thread.fromJson(Map<String, dynamic> json) {
    if (json['posts'] != null) {
      posts = <Post>[];
      json['posts'].forEach((v) {
        posts!.add(Post.fromJson(v));
      });
    }
    banned = json['banned'];
    board = json['board'];
    closed = json['closed'];
    comment = json['comment'];
    date = json['date'];
    email = json['email'];
    endless = json['endless'];
    if (json['files'] != null) {
      files = <File>[];
      json['files'].forEach((v) {
        files!.add(File.fromJson(v));
      });
    }
    filesCount = json['files_count'];
    lasthit = json['lasthit'];
    name = json['name'];
    num_ = json['num'];
    op = json['op'];
    parent = json['parent'];
    postsCount = json['posts_count'];
    sticky = json['sticky'];
    subject = json['subject'];
    tags = json['tags'];
    timestamp = json['timestamp'];
    trip = json['trip'];
    views = json['views'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (posts != null) {
      data['posts'] = posts!.map((v) => v.toJson()).toList();
    }
    data['banned'] = banned;
    data['board'] = board;
    data['closed'] = closed;
    data['comment'] = comment;
    data['date'] = date;
    data['email'] = email;
    data['endless'] = endless;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['files_count'] = filesCount;
    data['lasthit'] = lasthit;
    data['name'] = name;
    data['num'] = num_;
    data['op'] = op;
    data['parent'] = parent;
    data['posts_count'] = postsCount;
    data['sticky'] = sticky;
    data['subject'] = subject;
    data['tags'] = tags;
    data['timestamp'] = timestamp;
    data['trip'] = trip;
    data['views'] = views;
    return data;
  }
}

class File {
  String? displayname;
  String? fullname;
  int? height;
  String? md5;
  String? name;
  String? path;
  int? size;
  String? thumbnail;
  int? tnHeight;
  int? tnWidth;
  int? type;
  int? width;
  String? duration;
  int? durationSecs;
  String? install;
  String? pack;
  String? sticker;

  File(
      {this.displayname,
      this.fullname,
      this.height,
      this.md5,
      this.name,
      this.path,
      this.size,
      this.thumbnail,
      this.tnHeight,
      this.tnWidth,
      this.type,
      this.width,
      this.duration,
      this.durationSecs,
      this.install,
      this.pack,
      this.sticker});

  File.fromJson(Map<String, dynamic> json) {
    displayname = json['displayname'];
    fullname = json['fullname'];
    height = json['height'];
    md5 = json['md5'];
    name = json['name'];
    path = json['path'];
    size = json['size'];
    thumbnail = json['thumbnail'];
    tnHeight = json['tn_height'];
    tnWidth = json['tn_width'];
    type = json['type'];
    width = json['width'];
    duration = json['duration'];
    durationSecs = json['duration_secs'];
    install = json['install'];
    pack = json['pack'];
    sticker = json['sticker'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayname'] = displayname;
    data['fullname'] = fullname;
    data['height'] = height;
    data['md5'] = md5;
    data['name'] = name;
    data['path'] = path;
    data['size'] = size;
    data['thumbnail'] = thumbnail;
    data['tn_height'] = tnHeight;
    data['tn_width'] = tnWidth;
    data['type'] = type;
    data['width'] = width;
    data['duration'] = duration;
    data['duration_secs'] = durationSecs;
    data['install'] = install;
    data['pack'] = pack;
    data['sticker'] = sticker;
    return data;
  }
}

class Post {
  int? banned;
  String? board;
  int? closed;
  String? comment;
  String? date;
  String? email;
  int? endless;
  List<File>? files;
  int? lasthit;
  String? name;
  int? num_;
  int? number;
  int? op;
  int? parent;
  int? sticky;
  String? subject;
  String? tags;
  int? timestamp;
  String? trip;
  int? views;

  List<int> parents = List.empty(growable: true);
  Post(
      {this.banned,
      this.board,
      this.closed,
      this.comment,
      this.date,
      this.email,
      this.endless,
      this.files,
      this.lasthit,
      this.name,
      this.num_,
      this.number,
      this.op,
      this.parent,
      this.sticky,
      this.subject,
      this.tags,
      this.timestamp,
      this.trip,
      this.views});

  Post.fromJson(Map<String, dynamic> json) {
    banned = json['banned'];
    board = json['board'];
    closed = json['closed'];
    comment = json['comment'];
    date = json['date'];
    email = json['email'];
    endless = json['endless'];
    if (json['files'] != null) {
      files = <File>[];
      json['files'].forEach((v) {
        files!.add(File.fromJson(v));
      });
    }
    lasthit = json['lasthit'];
    name = json['name'];
    num_ = json['num'];
    number = json['number'];
    op = json['op'];
    parent = json['parent'];
    sticky = json['sticky'];
    subject = json['subject'];
    tags = json['tags'];
    timestamp = json['timestamp'];
    trip = json['trip'];
    views = json['views'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['banned'] = banned;
    data['board'] = board;
    data['closed'] = closed;
    data['comment'] = comment;
    data['date'] = date;
    data['email'] = email;
    data['endless'] = endless;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['lasthit'] = lasthit;
    data['name'] = name;
    data['num'] = num_;
    data['number'] = number;
    data['op'] = op;
    data['parent'] = parent;
    data['sticky'] = sticky;
    data['subject'] = subject;
    data['tags'] = tags;
    data['timestamp'] = timestamp;
    data['trip'] = trip;
    data['views'] = views;
    return data;
  }
}
