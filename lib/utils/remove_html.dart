import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

String removeHtmlTags(String htmlString) {
  var document = parse(htmlString);

  // Remove <a> tags
  var aTags = document.querySelectorAll('a');
  for (var aTag in aTags) {
    aTag.replaceWith(Text(null));
  }

  // Remove other specified tags while preserving their contents
  var otherTags = ['br', 'strong', 'sub', 'sup'];
  for (var tag in otherTags) {
    var tags = document.querySelectorAll(tag);
    for (var htmlElement in tags) {
      htmlElement.replaceWith(Text(htmlElement.innerHtml));
    }
  }

  return document.body!.text;
}
