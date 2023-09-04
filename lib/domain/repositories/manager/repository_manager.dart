abstract class RepositoryManager<T> {
  T add(T repo);
  remove(String tag, int id);
  T? get(String tag, int id);
}
