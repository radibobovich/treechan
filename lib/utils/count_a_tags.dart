int countATags(String text) {
  int count = 0;
  int index = 0;
  String substring = 'class="post-reply-link"';
  while (index < text.length) {
    index = text.indexOf(substring, index);
    if (index == -1) {
      break;
    }
    count++;
    index += substring.length;
  }
  return count;
}
