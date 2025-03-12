import 'package:flutter/material.dart';

import 'item_view.dart';
import '../pages.dart';
import '../saves.dart';

class CompletedBooks extends PageContent {
  const CompletedBooks({super.key});

  @override
  String title() { return "Completed books"; }

  @override
  State<CompletedBooks> createState() => _CompletedBooksState();
}

class _CompletedBooksState extends State<CompletedBooks> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text("Completed books",
          style: TextStyle(color: Theme.of(context).colorScheme.primary,),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: libraryData,
          builder: (BuildContext context, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                libraryData.completeItemCount() == 0 ? Expanded(
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
                          Text("Set a book's progress to\n100% to see it here!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: libraryData.completeItemCount(),
                    itemBuilder: (BuildContext context, int index) {
                      Item result = libraryData.completeItems()[index];

                      return ListTile(
                        key: Key('$index'),
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
                  )
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}