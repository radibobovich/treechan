import 'package:dynamic_treeview/dynamic_treeview.dart';
import '/board_json.dart';

class DataModel implements BaseData {
  final int? id;
  final int? parentId;
  String? name;

  Map<String, dynamic>? extras;
  DataModel({this.id, this.parentId, this.name, this.extras});

  @override
  String getId() {
    return this.id.toString();
  }

  @override
  String getParentId() {
    return this.parentId.toString();
  }

  @override
  String getTitle() {
    return this.name ?? "no name";
  }

  @override
  Map<String, dynamic> getExtraData() {
    return this.extras!;
  }
}
