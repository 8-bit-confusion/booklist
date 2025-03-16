import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../pages.dart';
import '../saves.dart';
import 'item_view.dart';

class ScanISBN extends PageContent {
  const ScanISBN({super.key});

  @override
  String title() { return "Scan ISBN"; }

  @override
  State<ScanISBN> createState() => _ScanISBNState();
}

class _ScanISBNState extends State<ScanISBN> {
  String cachedSearchTerm = "";
  Map<String, dynamic> searchResults = {};

  void getSearchResults(String searchTerm) async {
    Response searchResponse = await get(Uri(
      scheme: "https",
      host: "www.googleapis.com",
      path: "books/v1/volumes",
      queryParameters: {
        "q": searchTerm,
        "maxResults": settingsData.searchResultCount.toString(),
        "key": "AIzaSyDhId99_uWOE9apo1pMpzoZkkUHP7Ueawc",
      },
    ));

    setState(() {
      cachedSearchTerm = searchTerm;
      searchResults = jsonDecode(searchResponse.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: searchResults.isEmpty ? <Widget>[
          const SizedBox(height: 96.0,),
          Text(
            widget.title(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w400,
              fontSize: 32.0,
            ),
          ),
          const SizedBox(height: 16.0,),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: MobileScanner(
                onDetect: (BarcodeCapture capture) {
                  getSearchResults("isbn:${capture.barcodes.first.displayValue!}");
                },
              ),
            ),
          ),
        ] : <Widget>[
          const SizedBox(height: 48.0,),
          ListTile(
            title: Text("Scanned ISBN: \"$cachedSearchTerm\"",
              style: const TextStyle(fontWeight: FontWeight.w300,),),
            trailing: const Icon(Icons.close),
            onTap: () { setState(() {
              cachedSearchTerm = "";
              searchResults = {};
            }); },
          ),
          searchResults["items"] == null ? Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("No results found :(",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20.0,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  Text(
                    "We couldn't find any results for\n"
                    "\"$cachedSearchTerm\". Try searching\n"
                    "for the title or author instead.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ) : Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: searchResults["items"].length,
              itemBuilder: (BuildContext context, int index) {
                Item result = Item.fromBooksAPI(searchResults["items"][index]);

                return ListTile(
                  leading: Image(image: NetworkImage(result.thumbnailURL)),
                  title: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, result.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  subtitle: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, result.authors,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  trailing: libraryData.contains(result) ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(97),
                  ) : null,
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return ItemView(
                            item: result,
                          );
                        })
                    );
                    setState(() {});
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1.0, indent: 8.0, endIndent: 8.0,
                  color: Theme.of(context).colorScheme.inversePrimary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}