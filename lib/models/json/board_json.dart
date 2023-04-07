import "json.dart";

List<Board>? boardListFromJson(List<dynamic> json) {
  List<Board>? boardList = List.empty(growable: true);
  for (var boardItem in json) {
    boardList.add(Board.fromJson(boardItem));
  }
  return boardList;
}

List<Post> postListFromJson(List<dynamic> json) {
  List<Post> postList = List.empty(growable: true);
  for (var postItem in json) {
    postList.add(Post.fromJson(postItem));
  }
  return postList;
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

  //position in favorite list
  int? position;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Board && id == other.id && name == other.name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  Board({
    this.bumpLimit,
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
    this.threadsPerPage,
    required description,
    this.position,
  });

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
    position = json['position'];
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
    data['position'] = position;
    return data;
  }
}
