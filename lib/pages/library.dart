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
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                              TextButton.icon(
                                style: const ButtonStyle(
                                  splashFactory: null,
                                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                                  padding: WidgetStatePropertyAll(EdgeInsets.all(4.0)),
                                  minimumSize: WidgetStatePropertyAll(Size.zero),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(Icons.sort, size: 18.0, color: Theme.of(context).colorScheme.primary,),
                                label: Text("Sort by: ${SettingsData.methodNames[settingsData.sortMethod]}",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12.0,
                                    color: Theme.of(context).colorScheme.primary,),),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: Text(
                                          "Sort library by:",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            RadioListTile(
                                              value: SortMethod.custom,
                                              groupValue: settingsData.sortMethod,
                                              dense: true,
                                              title: Text("Custom", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                                color: Theme.of(context).colorScheme.primary,),),
                                              onChanged: (SortMethod? value) {
                                                if (value != null) {
                                                  setState(() { settingsData.setSortMethod(value); });
                                                }
                                              },
                                            ),
                                            RadioListTile(
                                              value: SortMethod.recent,
                                              groupValue: settingsData.sortMethod,
                                              dense: true,
                                              title: Text("Most recent", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                                color: Theme.of(context).colorScheme.primary,),),
                                              onChanged: (SortMethod? value) {
                                                if (value != null) {
                                                  setState(() { settingsData.setSortMethod(value); });
                                                }
                                              },
                                            ),
                                            RadioListTile(
                                              value: SortMethod.title,
                                              groupValue: settingsData.sortMethod,
                                              dense: true,
                                              title: Text("Title (A-Z)", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                                color: Theme.of(context).colorScheme.primary,),),
                                              onChanged: (SortMethod? value) {
                                                if (value != null) {
                                                  setState(() { settingsData.setSortMethod(value); });
                                                }
                                              },
                                            ),
                                            RadioListTile(
                                              value: SortMethod.author,
                                              groupValue: settingsData.sortMethod,
                                              dense: true,
                                              title: Text("Author's name (A-Z)", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                                color: Theme.of(context).colorScheme.primary,),),
                                              onChanged: (SortMethod? value) {
                                                if (value != null) {
                                                  setState(() { settingsData.setSortMethod(value); });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                  );
                                },
                              )
                            ],
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            List<Item> renderedItems = settingsData.showCompletedBooks ? libraryData.items() : libraryData.incompleteItems();
                            List<Item> sortedItems = renderedItems.toList()..sort(SettingsData.methodImplementation[settingsData.sortMethod]);
                            Item result = sortedItems[index];

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