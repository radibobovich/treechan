import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(const App());
}

class HtmlTester extends StatelessWidget {
  const HtmlTester({super.key});
  static const String data =
      // ignore: unnecessary_string_escapes
      '<style type=\"text/css\">.pr-tags-container {display: -webkit-flex;-webkit-flex-wrap: wrap;display: flex;flex-wrap: wrap;}.pr-tags-container > a {display: block;border-radius: 4px;text-decoration: none;border: none;text-align: center;padding: 10px;transition: all 0.3s;cursor: pointer;color: #fff;background-color: #FF6600;font-size: 10pt;margin: 3px;}.pr-tags-container > a:hover {background-color: #d65600;color: #fff;}.pr-tags-title {padding-top: 14px;font-weight: bold;}.pr-tags-table td {border: none !important;margin-bottom: 5px;}.pr-link {color: #FF6600;}.pr-link:visited {color: #FF6600;}.pr-tags-table {max-width: 750px;}</style><h2>Первый раз здесь? Задавай вопрос в <a class=\"pr-link\" href=\"https://2ch.hk/pr/res/1008826.html\">этом</a> треде.</h2><h4>Большие куски кода желательно вставлять через <a class=\"pr-link\" href=\"https://ideone.com/\">ideone</a> или <a class=\"pr-link\" href=\"https://pastebin.com/\">pastebin</a>.</h4><table class=\"pr-tags-table\"><tr><td class=\"pr-tags-title\">Mobile:</td><td class=\"pr-tags-container\"><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"android\">Android </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"ios\">IOS </a></td></tr><tr><td class=\"pr-tags-title\">Enterprise:</td><td class=\"pr-tags-container\"><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"java\">Java </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"csharp\">C# </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"go\">Go </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"1c\">1С </a></td></tr><tr><td class=\"pr-tags-title\">Interpreted:</td><td class=\"pr-tags-container\"><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"js\">Javascript</a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"python\">Python </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"php\">PHP </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"ruby\">Ruby </a></td></tr><tr><td class=\"pr-tags-title\">Functional: </td><td class=\"pr-tags-container\"><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"haskell\">Haskell </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"lisp\">Lisp </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"ocaml\">OCaml </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"clojure\">Clojure(Script) </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"scala\">Scala </a></td></tr><tr><td class=\"pr-tags-title\">System:</td><td class=\"pr-tags-container\"><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"clang\">C </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"asm\">ASM </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"cpp\">C++ </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"rust\">Rust </a></td></tr><tr><td class=\"pr-tags-title\">Other:</td><td class=\"pr-tags-container\"><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"compsci\">Computer Science </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"ai\">Нейроночки и МашОб </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"gamedev\">Gamedev </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"xo\">Мы вам перезвоним </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"sicp\">SICP </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"sql\">Базы данных </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"vcs\">Version control </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"ideas\">Идеи анона </a><a class=\"hashlink\" href=\"/pr/catalog.html\" title=\"remote\">Freelance </a></td></tr></table>';
  @override
  Widget build(BuildContext context) {
    return Html(data: data);
  }
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              HtmlTester(),
              Text('Конец'),
            ],
          ),
        ),
      ),
    );
  }
}
