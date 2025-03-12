import 'dart:math';

import 'package:flutter/material.dart';

import '../saves.dart';

class ItemView extends StatefulWidget {
  const ItemView({
    super.key,
    required this.item,
  });

  final Item item;

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  final GlobalKey<FormState> _progressKey = GlobalKey();
  final GlobalKey<FormState> _pageCountKey = GlobalKey();
  final ScrollController _controller = ScrollController();

  final GlobalKey _sizeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(libraryData.contains(widget.item) ? Icons.check_circle : Icons.add,),
            onPressed: libraryData.contains(widget.item) ? null : () {
              setState(() { libraryData.add(widget.item); });
            },
          )
        ],
      ),
      body: ListView(
        controller: _controller,
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 72.0),
            child: Container(
              key: _sizeKey,
              height: widget.item.coverURL != null ? null : 256,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                boxShadow: [BoxShadow(
                  blurRadius: 16.0,
                  offset: const Offset(0.0, 8.0),
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
                )],
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.item.coverURL != null ? Image(
                fit: BoxFit.fitWidth,
                image: NetworkImage(widget.item.coverURL!),
              ) : Center(
                child: Text(
                  "No Cover\nAvailable",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0,),
          Text(
            widget.item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
            ),
          ),
          Text(
            widget.item.authors,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.3),
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 8.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  minimumSize: WidgetStatePropertyAll(Size(0.0, 0.0)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                ),
                onPressed: null,
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          "Override Page Count",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
                        content: Form(
                          key: _pageCountKey,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "New page count",
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
                            ),
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (String value) {
                              if (int.tryParse(value) != null) {
                                int pages = max(int.parse(value), 0);
                                setState(() { libraryData.overridePageCount(widget.item, pages); });
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      )
                  );
                },
                child: Text(
                  "${widget.item.pageCount} pages",
                  style: TextStyle(
                    color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.1),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                ),
              ), // override page count
              Text(" · ",
                style: TextStyle(
                  color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.1),
                  fontWeight: FontWeight.w400,
                  fontSize: 12.0,
                ),
              ),
              TextButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  minimumSize: WidgetStatePropertyAll(Size(0.0, 0.0)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                ),
                onPressed: null,
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          "Override Category",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
                        content: Form(
                          key: _pageCountKey,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "New category",
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
                            ),
                            onFieldSubmitted: (String value) {
                              if (value.isNotEmpty) {
                                setState(() { libraryData.overrideCategory(widget.item, value); });
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      )
                  );
                },
                child: Text(
                  widget.item.category,
                  style: TextStyle(
                    color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.1),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                ),
              ), // override category
              Text(" · ",
                style: TextStyle(
                  color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.1),
                  fontWeight: FontWeight.w400,
                  fontSize: 12.0,
                ),
              ),
              TextButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  minimumSize: WidgetStatePropertyAll(Size(0.0, 0.0)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                ),
                onPressed: null,
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          "Override Publication Date",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
                        content: Form(
                          key: _pageCountKey,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "New publication date",
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
                            ),
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (String value) {
                              if (value.isNotEmpty) {
                                setState(() { libraryData.overridePublicationDate(widget.item, value); });
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      )
                  );
                },
                child: Text(
                  widget.item.publishedDate,
                  style: TextStyle(
                    color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.1),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                ),
              ), // override publication date
            ],
          ),

          const SizedBox(height: 32.0,),
          libraryData.contains(widget.item) ? OutlinedButton(
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.all(16.0)),
              shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              )),
              side: WidgetStatePropertyAll(BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
              )),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    "Set Progress",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16.0,
                    ),
                  ),
                  content: Form(
                    key: _progressKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Pages read",
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
                      ),
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (String value) {
                        if (int.tryParse(value) != null) {
                          int pages = int.parse(value).clamp(0, widget.item.pageCount);
                          setState(() { libraryData.setProgress(widget.item, pages); });
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                )
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.item.pageCount != 0 ? LinearProgressIndicator(
                  value: libraryData.getProgress(widget.item) / widget.item.pageCount,
                  minHeight: 4.0,
                  borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                ) : Container(),
                widget.item.pageCount != 0 ? const SizedBox(height: 8.0,) : Container(),
                Text(
                  "Reading progress: ${libraryData.getProgress(widget.item)} / ${widget.item.pageCount} "
                      "${widget.item.pageCount != 0 ? "(${(1000 * libraryData.getProgress(widget.item) / widget.item.pageCount).round() / 10.0}%)" : ""}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w300,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ) : Container(),
          libraryData.contains(widget.item) ? const SizedBox(height: 12.0,) : Container(),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Text(
              widget.item.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w300,
                fontSize: 14.0,
              ),
            ),
          ),
          const SizedBox(height: 8.0,),
          libraryData.contains(widget.item) ? OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error,),
            ),
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error,),
            iconAlignment: IconAlignment.end,
            label: const Text(
              "Remove from Library",
              style: TextStyle(fontWeight: FontWeight.w300,),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    "Remove from Library",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16.0,
                    ),
                  ),
                  content: Text(
                    "This book and its progress will be removed from your library. This action cannot be undone.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("CANCEL"),
                      onPressed: () => Navigator.of(context).pop()
                    ),
                    TextButton(
                      child: Text("REMOVE",
                        style: TextStyle(color: Theme.of(context).colorScheme.error,),),
                      onPressed: () {
                        setState(() { libraryData.remove(widget.item); });
                        Navigator.of(context).pop();
                        _controller.jumpTo(0.0);
                      }
                    )
                  ],
                )
              );
            },
          ) : Container(),
          libraryData.contains(widget.item) ? const SizedBox(height: 24.0,) : Container(),
        ]
      ),
    );
  }
}