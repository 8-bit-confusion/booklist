import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart' as html_parser;

Future<List<String>> getGenre(String itemID) async {
  Uri targetUri = Uri(
    scheme: "https",
    host: "www.google.com",
    path: "books/edition/_/$itemID",
  );

  Response genreResponse = await get(
    targetUri,
    headers: {
      "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
    }
  );

  String html = genreResponse.body;
  if (!html.contains("Genres")) return ["No genres found"];

  Document document = html_parser.parse(html);

  return document.getElementsByClassName("zloOqf")
      .where((Element category) => category.children[0].text == "Genres: ")
      .map((Element category) => category.children[1].children[0].children).toList()[0]
      .map((Element genreLink) => genreLink.text).toList();
}