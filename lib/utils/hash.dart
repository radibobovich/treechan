int hashStringAndInt(String str, int intValue) {
  int strHashCode = str.hashCode;
  int intHashCode = intValue.hashCode;

  int combinedHashCode = strHashCode ^ intHashCode;

  if (combinedHashCode < 0) {
    combinedHashCode = -combinedHashCode;
  }

  return combinedHashCode;
}
