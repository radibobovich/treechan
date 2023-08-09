import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

/// Removes markdown from comment.
/// Use [links] = false to remove reply links too
/// Use [replaceBr] = true to replace <br> with \n
String removeHtmlTags(String htmlString,
    {bool links = true, bool replaceBr = false}) {
  var document = parse(htmlString);

  // Remove <a> tags
  var aTags = document.querySelectorAll('a');
  for (var aTag in aTags) {
    if (links) {
      aTag.replaceWith(Text(aTag.innerHtml.replaceAll('&gt;', '>')));
    } else {
      aTag.replaceWith(Text(null));
    }
  }

  // Remove other specified tags while preserving their contents
  var otherTags = ['strong', 'sub', 'sup'];
  if (!replaceBr) {
    otherTags.add('br');
  } else {
    var brTags = document.querySelectorAll('br');
    for (var tag in brTags) {
      tag.replaceWith(Text('\n'));
    }
  }
  for (var tag in otherTags) {
    var tags = document.querySelectorAll(tag);
    for (var htmlElement in tags) {
      htmlElement.replaceWith(Text(htmlElement.innerHtml));
    }
  }

  return document.body!.text;
}
