class Root {
  String? advertMobileImage;
  String? advertMobileLink;
  Board? board;
  String? boardBannerImage;
  String? boardBannerLink;
  String? filter;
  List<Thread>? threads;

  Root(
      {this.advertMobileImage,
      this.advertMobileLink,
      this.board,
      this.boardBannerImage,
      this.boardBannerLink,
      this.filter,
      this.threads});

  Root.fromJson(Map<String, dynamic> json) {
    advertMobileImage = json['advert_mobile_image'];
    advertMobileLink = json['advert_mobile_link'];
    board = json['board'] != null ? new Board.fromJson(json['board']) : null;
    boardBannerImage = json['board_banner_image'];
    boardBannerLink = json['board_banner_link'];
    filter = json['filter'];
    if (json['threads'] != null) {
      threads = <Thread>[];
      json['threads'].forEach((v) {
        threads!.add(new Thread.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['advert_mobile_image'] = this.advertMobileImage;
    data['advert_mobile_link'] = this.advertMobileLink;
    if (this.board != null) {
      data['board'] = this.board!.toJson();
    }
    data['board_banner_image'] = this.boardBannerImage;
    data['board_banner_link'] = this.boardBannerLink;
    data['filter'] = this.filter;
    if (this.threads != null) {
      data['threads'] = this.threads!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bump_limit'] = this.bumpLimit;
    data['category'] = this.category;
    data['default_name'] = this.defaultName;
    data['enable_dices'] = this.enableDices;
    data['enable_flags'] = this.enableFlags;
    data['enable_icons'] = this.enableIcons;
    data['enable_likes'] = this.enableLikes;
    data['enable_names'] = this.enableNames;
    data['enable_oekaki'] = this.enableOekaki;
    data['enable_posting'] = this.enablePosting;
    data['enable_sage'] = this.enableSage;
    data['enable_shield'] = this.enableShield;
    data['enable_subject'] = this.enableSubject;
    data['enable_thread_tags'] = this.enableThreadTags;
    data['enable_trips'] = this.enableTrips;
    data['file_types'] = this.fileTypes;
    data['id'] = this.id;
    data['info'] = this.info;
    data['info_outer'] = this.infoOuter;
    data['max_comment'] = this.maxComment;
    data['max_files_size'] = this.maxFilesSize;
    data['max_pages'] = this.maxPages;
    data['name'] = this.name;
    data['threads_per_page'] = this.threadsPerPage;
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
  int? num;
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
      this.num,
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
        files!.add(new File.fromJson(v));
      });
    }
    filesCount = json['files_count'];
    lasthit = json['lasthit'];
    name = json['name'];
    num = json['num'];
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banned'] = this.banned;
    data['board'] = this.board;
    data['closed'] = this.closed;
    data['comment'] = this.comment;
    data['date'] = this.date;
    data['email'] = this.email;
    data['endless'] = this.endless;
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    data['files_count'] = this.filesCount;
    data['lasthit'] = this.lasthit;
    data['name'] = this.name;
    data['num'] = this.num;
    data['op'] = this.op;
    data['parent'] = this.parent;
    data['posts_count'] = this.postsCount;
    data['sticky'] = this.sticky;
    data['subject'] = this.subject;
    data['tags'] = this.tags;
    data['timestamp'] = this.timestamp;
    data['trip'] = this.trip;
    data['views'] = this.views;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayname'] = this.displayname;
    data['fullname'] = this.fullname;
    data['height'] = this.height;
    data['md5'] = this.md5;
    data['name'] = this.name;
    data['path'] = this.path;
    data['size'] = this.size;
    data['thumbnail'] = this.thumbnail;
    data['tn_height'] = this.tnHeight;
    data['tn_width'] = this.tnWidth;
    data['type'] = this.type;
    data['width'] = this.width;
    data['duration'] = this.duration;
    data['duration_secs'] = this.durationSecs;
    data['install'] = this.install;
    data['pack'] = this.pack;
    data['sticker'] = this.sticker;
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
  int? num;
  int? number;
  int? op;
  int? parent;
  int? sticky;
  String? subject;
  String? tags;
  int? timestamp;
  String? trip;
  int? views;

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
      this.num,
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
        files!.add(new File.fromJson(v));
      });
    }
    lasthit = json['lasthit'];
    name = json['name'];
    num = json['num'];
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banned'] = this.banned;
    data['board'] = this.board;
    data['closed'] = this.closed;
    data['comment'] = this.comment;
    data['date'] = this.date;
    data['email'] = this.email;
    data['endless'] = this.endless;
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    data['lasthit'] = this.lasthit;
    data['name'] = this.name;
    data['num'] = this.num;
    data['number'] = this.number;
    data['op'] = this.op;
    data['parent'] = this.parent;
    data['sticky'] = this.sticky;
    data['subject'] = this.subject;
    data['tags'] = this.tags;
    data['timestamp'] = this.timestamp;
    data['trip'] = this.trip;
    data['views'] = this.views;
    return data;
  }
}
