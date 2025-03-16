import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'item_view.dart';
import '../pages.dart';
import '../saves.dart';
import '../settings_launcher.dart';


class Search extends PageContent {
  const Search({super.key});

  @override
  String title() { return "Search"; }

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _formFocus = FocusNode();
  final ScrollController _controller = ScrollController();

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
      searchResults = jsonDecode(searchResponse.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsLauncher(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: (searchResults.isEmpty ? <Widget>[
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
            const SizedBox(height: 8.0,),
          ] : <Widget>[
            const SizedBox(height: 48.0,),
          ]) + [
            Form(
              key: _formKey,
              child: TextFormField(
                focusNode: _formFocus,
                decoration: InputDecoration(
                  helperText: "Powered by the Google Books API",
                  helperStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w300,
                  ),
                  hintText: "Title, Author or Keyword",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w300,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondaryContainer,
                  hoverColor: Colors.transparent,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  suffixIcon: searchResults.isNotEmpty ?
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() { searchResults.clear(); });
                      _formKey.currentState!.reset();
                      _formFocus.requestFocus();
                    },
                  ) : null,
                  suffixIconColor: Theme.of(context).colorScheme.primary,
                ),
                style: const TextStyle(fontWeight: FontWeight.w300,),
                onFieldSubmitted: (String value) {
                  if (value == "") return;
                  if (searchResults.isNotEmpty) _controller.jumpTo(0.0);
                  getSearchResults(value);
                },
              ),
            ),
            const SizedBox(height: 16.0,),
            searchResults.isEmpty ? Container() :
            Expanded(
              child: ListView.separated(
                controller: _controller,
                itemCount: searchResults["items"] != null ? searchResults["items"].length : 0,
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
      ),
      active: searchResults.isEmpty,
    );
  }
}