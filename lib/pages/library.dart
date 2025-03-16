import 'package:booklist/pages/completed_books.dart';
import 'package:flutter/material.dart';

import 'settings.dart';
import 'item_view.dart';
import '../pages.dart';
import '../saves.dart';

class Library extends PageContent {
  const Library({super.key});

  @override
  String title() { return "Library"; }

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            actions: <Widget>[IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const Settings();
                    })
                );
              },
            )],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: ListenableBuilder(
            listenable: libraryData,
            builder: (BuildContext context, Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                  libraryData.length == 0 ? Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("There's nothing here yet...",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20.0,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            Text("Search or scan a barcode below\nto start adding books!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w300,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ) : Expanded(
                    child: ListenableBuilder(
                      listenable: settingsData,
                      builder: (BuildContext context, Widget? child) {
                        return ReorderableListView.builder(
                          scrollController: _controller,
                          itemCount: settingsData.showCompletedBooks ? libraryData.length : libraryData.incompleteItemCount(),
                          onReorder: (int startIndex, int endIndex) {
                            libraryData.reorder(startIndex, endIndex);
                          },
                          header: Column(
                            children: [
                              Divider(height: 1.0, thickness: 1.0,
                                color: Theme.of(context).colorScheme.primary.withAlpha(64),),
                              ListTile(
                                title: const Text("Completed books", style: TextStyle(fontWeight: FontWeight.w300,),),
                                trailing: const Icon(Icons.chevron_right,),
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return const CompletedBooks();
                                    })
                                ),
                              ),
                              Divider(height: 1.0, thickness: 1.0,
                                color: Theme.of(context).colorScheme.primary.withAlpha(64),),
                            ],
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            Item result = settingsData.showCompletedBooks ? libraryData[index] : libraryData.incompleteItems()[index];

                            return ListTile(
                              key: Key('$index'),
                              leading: libraryData.isCompleted(result) ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image(
                                    image: NetworkImage(result.thumbnailURL),
                                    opacity: const AlwaysStoppedAnimation(0.5),
                                  ),
                                  const Icon(Icons.check_circle, size: 32.0),
                                ],
                              ) : Image(image: NetworkImage(result.thumbnailURL),),
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
                        );
                      },
                    )
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}