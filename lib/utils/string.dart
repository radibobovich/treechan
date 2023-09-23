String truncate(String input, int n, {bool ellipsis = false}) {
  if (input.length <= n) {
    return input;
  } else {
    if (ellipsis) {
      return '${input.substring(0, n)}...';
    }
    return input.substring(0, n);
  }
}
