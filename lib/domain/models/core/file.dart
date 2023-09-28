import '../api/dvach/post_dvach_api_model.dart';

class File {
  final String name;
  final String fullName;
  final String displayName;
  String path;
  String thumbnail;
  final int type;
  final int size;
  final int width;
  final int height;
  final int tnWidth;
  final int tnHeight;
  final String? md5;
  final String? duration;
  final int? durationSecs;
  final String? install;
  final String? pack;
  final String? sticker;

  File({
    required this.name,
    required this.fullName,
    required this.displayName,
    required this.path,
    required this.thumbnail,
    required this.type,
    required this.size,
    required this.width,
    required this.height,
    required this.tnWidth,
    required this.tnHeight,
    this.md5,
    this.duration,
    this.durationSecs,
    this.install,
    this.pack,
    this.sticker,
  });

  File.fromFileDvachApi(FileDvachApiModel file)
      : name = file.name,
        fullName = file.fullname,
        displayName = file.displayname,
        path = file.path,
        thumbnail = file.thumbnail,
        type = file.type,
        size = file.size,
        width = file.width,
        height = file.height,
        tnWidth = file.tn_width,
        tnHeight = file.tn_height,
        md5 = file.md5,
        duration = file.duration,
        durationSecs = file.duration_secs,
        install = file.install,
        pack = file.pack,
        sticker = file.sticker;
}
