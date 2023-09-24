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

enum ExtractMode { name, info }

String extractUserInfo(String html, {ExtractMode mode = ExtractMode.name}) {
  // Remove HTML markup and colors
  final htmlWithoutMarkup = html.replaceAll(RegExp(r'<[^>]*>'), '');

  // Remove color styles (e.g., style="color:rgb(164,164,164);")
  final htmlWithoutColors = htmlWithoutMarkup.replaceAll(
      RegExp(r'style="color:\s*rgb\(\d+,\d+,\d+\);?"'), '');

  // Replace HTML entities (e.g., &nbsp;) with their actual characters
  final cleanedHtml = htmlWithoutColors
      .replaceAll(RegExp(r'&nbsp;'), ' ')
      .replaceAll(RegExp(r'&amp;'), '&');

  final trimmedHtml = cleanedHtml.trim();

  if (mode == ExtractMode.name) {
    if (trimmedHtml[0] == '(') {
      return '';
    }
    final name = trimmedHtml.split(' ')[0];
    return name;
  } else {
    if (trimmedHtml[0] == '(') {
      return trimmedHtml;
    }
    final info = trimmedHtml.split(' ').sublist(1).join(' ');
    return info;
  }
}
