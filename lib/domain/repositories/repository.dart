import 'package:treechan/utils/constants/enums.dart';

abstract class Repository {
  abstract Imageboard imageboard;
  String get boardTag;
  int get id;
  load();
}
