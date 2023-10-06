import 'package:treechan/utils/constants/enums.dart';

abstract class RepositoryManager<T> {
  T add(T repo);
  remove(Imageboard imageboard, String tag, int id);
  T? get(Imageboard imageboard, String tag, int id);
}
