import "json.dart";

class Thread {
  // Don't use commented fields, use posts[0] fields instead
  // int? banned;
  // String? board;
  // int? closed;
  // String? comment;
  // String? date;
  // String? email;
  // int? endless;
  // List<File>? files;
  int? filesCount;
  // int? lasthit;
  // String? name;
  // int? num_;
  // int? op;
  // int? parent;
  int? postsCount;
  // int? sticky;
  // String? subject;
  // String? tags;
  // int? timestamp;
  // String? trip;
  // int? views;
  List<Post> posts = [];

  Thread({
    // this.banned,
    // this.board,
    // this.closed,
    // this.comment,
    // this.date,
    // this.email,
    // this.endless,
    // this.files,
    this.filesCount,
    // this.lasthit,
    // this.name,
    // this.num_,
    // this.op,
    // this.parent,
    this.postsCount,
    // this.sticky,
    // this.subject,
    // this.tags,
    // this.timestamp,
    // this.trip,
    // this.views,
    // this.posts
  });

  Thread.fromJson(Map<String, dynamic> json) {
    if (json['posts'] != null) {
      posts = <Post>[];
      json['posts'].forEach((v) {
        posts.add(Post.fromJson(v));
      });
    }

    // banned = json['banned'];
    // board = json['board'];
    // closed = json['closed'];
    // comment = json['comment'];
    // date = json['date'];
    // email = json['email'];
    // endless = json['endless'];
    // if (json['files'] != null) {
    //   files = <File>[];
    //   json['files'].forEach((v) {
    //     files!.add(File.fromJson(v));
    //   });
    // }
    filesCount = json['files_count'];
    // lasthit = json['lasthit'];
    // name = json['name'];
    // num_ = json['num'];
    // op = json['op'];
    // parent = json['parent'];
    postsCount = json['posts_count'];
    // sticky = json['sticky'];
    // subject = json['subject'];
    // tags = json['tags'];
    // timestamp = json['timestamp'];
    // trip = json['trip'];
    // views = json['views'];
    // fix non existing post of thread while getting threads from board
    if (posts.isEmpty) {
      final List<File> files = [];
      if (json['files'] != null) {
        json['files'].forEach((v) {
          files.add(File.fromJson(v));
        });
      }
      final Post post = Post(
        banned: json['banned'],
        board: json['board'],
        closed: json['closed'],
        comment: json['comment'],
        date: json['date'],
        email: json['email'],
        endless: json['endless'],
        files: files,
        lasthit: json['lasthit'],
        name: json['name'],
        id: json['num'],
        op: json['op'],
        parent: json['parent'],
        sticky: json['sticky'],
        subject: json['subject'],
        tags: json['tags'],
        timestamp: json['timestamp'],
        trip: json['trip'],
        views: json['views'],
      );
      posts.add(post);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['posts'] = posts.map((v) => v.toJson()).toList();
    // data['banned'] = banned;
    // data['board'] = board;
    // data['closed'] = closed;
    // data['comment'] = comment;
    // data['date'] = date;
    // data['email'] = email;
    // data['endless'] = endless;
    // if (files != null) {
    //   data['files'] = files!.map((v) => v.toJson()).toList();
    // }
    data['files_count'] = filesCount;
    // data['lasthit'] = lasthit;
    // data['name'] = name;
    // data['num'] = num_;
    // data['op'] = op;
    // data['parent'] = parent;
    data['posts_count'] = postsCount;
    // data['sticky'] = sticky;
    // data['subject'] = subject;
    // data['tags'] = tags;
    // data['timestamp'] = timestamp;
    // data['trip'] = trip;
    // data['views'] = views;
    return data;
  }
}
