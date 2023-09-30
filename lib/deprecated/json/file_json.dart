@Deprecated('Use File from models/core instead')
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
