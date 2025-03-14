import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Item {
  static String imageURL(String contentID, int zoom) {
    return "https://books.google.com/books/content?id=$contentID&printsec=frontcover&img=1&zoom=$zoom&source=gbs_api";
  }

  final String id;
  final String title;
  final String authors;
  final String description;
  int pageCount;
  String category;
  String publishedDate;
  final String thumbnailURL;
  final String? coverURL;

  Item({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.pageCount,
    required this.category,
    required this.publishedDate,
    required this.thumbnailURL,
    required this.coverURL,
  });

  factory Item.fromBooksAPI(Map<String, dynamic> data) {
    bool hasAuthors = data["volumeInfo"]["authors"] != null;
    bool hasCategories = data["volumeInfo"]["categories"] != null;
    bool hasDate = data["volumeInfo"]["publishedDate"] != null;
    bool hasImages = data["volumeInfo"]["imageLinks"] != null;

    return Item(
      id: data["id"],
      title: data["volumeInfo"]["title"],
      authors: hasAuthors ? data["volumeInfo"]["authors"].join(", ") : "No authors listed",
      description: data["volumeInfo"]["description"] ?? "No description available",
      pageCount: data["volumeInfo"]["pageCount"] ?? 0,
      category: hasCategories ? data["volumeInfo"]["categories"].join(", ") : "[no category]",
      publishedDate: hasDate ? data["volumeInfo"]["publishedDate"].substring(0, 4) : "[no date]",
      thumbnailURL: hasImages ? Item.imageURL(data["id"], 1) : "https://books.google.com/googlebooks/images/no_cover_thumb.gif",
      coverURL: hasImages ? Item.imageURL(data["id"], 3) : null,
    );
  }

  Item.fromJson(Map<String, dynamic> data) : this(
    id: data["id"],
    title: data["title"],
    authors: data["authors"],
    description: data["description"],
    pageCount: data["pageCount"],
    category: data["category"],
    publishedDate: data["publishedDate"],
    thumbnailURL: data["thumbnailURL"],
    coverURL: Item.imageURL(data["id"], 3),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "authors": authors,
    "description": description,
    "pageCount": pageCount,
    "category": category,
    "publishedDate": publishedDate,
    "thumbnailURL": thumbnailURL,
    "coverURL": coverURL,
  };
}

class SyncedData with ChangeNotifier {
  late File dataFile;

  void syncToSave() {
    notifyListeners();
    dataFile.writeAsStringSync(jsonEncode(toJson()));
  }

  void setDefaults() {}

  void syncFromSave() {
    notifyListeners();
    if (dataFile.existsSync()) {
      loadFromJson(jsonDecode(dataFile.readAsStringSync()));
    } else {
      setDefaults();
      syncToSave();
    }
  }

  void loadFromJson(Map<String, dynamic> data) {}
  Map<String, dynamic> toJson() => {};
}

class LibraryData extends SyncedData {
  late List<String> library;
  late Map<String, Item> libraryItems;
  late Map<String, int> libraryProgress;

  static const String dataFileName = "libData.books";

  LibraryData() {
    dataFile = File("${storageRoot.path}/$dataFileName");
    syncFromSave();
  }

  @override
  void setDefaults() {
    library = [];
    libraryItems = {};
    libraryProgress = {};
  }

  @override
  void loadFromJson(Map<String, dynamic> data) {
    library = data["library"].map<String>((dynamic value) => value.toString()).toList();
    libraryItems = data["libraryItems"].map<String, Item>((String key, dynamic value) => MapEntry(key, Item.fromJson(value)));
    libraryProgress = data["libraryProgress"].map<String, int>((String key, dynamic value) => MapEntry(key, value as int));
  }

  @override
  Map<String, dynamic> toJson() => {
    "library": library,
    "libraryItems": libraryItems.map((String key, Item value) => MapEntry(key, value.toJson())),
    "libraryProgress": libraryProgress.map((String key, int value) => MapEntry(key, value)),
  };

  String? export() {
    String dateTime = DateTime.now().toString();
    dateTime = dateTime.substring(0, dateTime.indexOf("."));
    dateTime = dateTime.replaceAll(RegExp("[:-]"), "");
    dateTime = dateTime.replaceAll(" ", "_");

    String? filename = "books-$dateTime.json";

    File saveFile = File("${downloads!.path}/$filename");
    saveFile.writeAsStringSync(jsonEncode(toJson()), flush: true);

    return filename;
  }

  void import(File importFile) {
    notifyListeners();
    loadFromJson(jsonDecode(importFile.readAsStringSync()));
    syncToSave();
  }

  get isEmpty => library.isEmpty;
  get length => library.length;

  operator [](int index) => libraryItems[library[index]];

  bool contains(Item item) {
    return libraryItems.containsKey(item.id);
  }

  bool isCompleted(Item item) => item.pageCount == libraryProgress[item.id];

  List<Item> completeItems() => library
      .where((String id) => libraryItems[id]!.pageCount == libraryProgress[id])
      .map((String id) => libraryItems[id]!)
      .toList();
  int completeItemCount() => completeItems().length;

  List<Item> incompleteItems() => library
      .where((String id) => libraryItems[id]!.pageCount != libraryProgress[id])
      .map((String id) => libraryItems[id]!)
      .toList();
  int incompleteItemCount() => incompleteItems().length;

  int getProgress(Item item) {
    if (!libraryProgress.containsKey(item.id)) { libraryProgress[item.id] = 0; }
    return libraryProgress[item.id]!;
  }

  void add(Item item) {
    library.insert(0, item.id);
    libraryItems[item.id] = item;
    libraryProgress[item.id] = 0;
    syncToSave();
  }

  void remove(Item item) {
    library.remove(item.id);
    libraryItems.remove(item.id);
    libraryProgress.remove(item.id);
    syncToSave();
  }

  void reorder(int startIndex, int endIndex) {
    int offset = startIndex < endIndex ? -1 : 0;
    library.insert(endIndex + offset, library.removeAt(startIndex));
    syncToSave();
  }

  void setProgress(Item item, int newProgress) {
    libraryProgress[item.id] = newProgress;
    syncToSave();
  }

  void overridePageCount(Item item, int newPageCount) {
    item.pageCount = newPageCount;
    if (getProgress(item) > newPageCount) setProgress(item, newPageCount);
    syncToSave();
  }

  void overrideCategory(Item item, String newCategory) {
    item.category = newCategory;
  }

  void overridePublicationDate(Item item, String newPublicationDate) {
    item.publishedDate = newPublicationDate;
  }
}

class SettingsData extends SyncedData {
  late Color seedColor;
  late ThemeMode themeMode;
  late int searchResultCount;
  late bool showCompletedBooks;

  static const String dataFileName = "settingsData.books";

  static Map<Color, String> colorNames = {
    Colors.amber: "Amber",
    Colors.blue: "Blue",
    Colors.cyan: "Cyan",
    Colors.deepOrange: "Deep orange",
    Colors.deepPurple: "Deep purple",
    Colors.green: "Green",
    Colors.indigo: "Indigo",
    Colors.lightBlue: "Light blue",
    Colors.lightGreen: "Light green",
    Colors.lime: "Lime",
    Colors.orange: "Orange",
    Colors.pink: "Pink",
    Colors.purple: "Purple",
    Colors.red: "Red",
    Colors.teal: "Teal",
    Colors.yellow: "Yellow",
  };

  static Map<String, Color> colorValues = Map.fromIterables(colorNames.values, colorNames.keys);

  static Map<ThemeMode, String> modeNames = {
    ThemeMode.light: "light",
    ThemeMode.dark: "dark",
    ThemeMode.system: "system",
  };

  static Map<String, ThemeMode> modeValues = Map.fromIterables(modeNames.values, modeNames.keys);

  SettingsData() {
    dataFile = File("${storageRoot.path}/$dataFileName");
    syncFromSave();
  }

  @override
  void setDefaults() {
    seedColor = Colors.amber;
    themeMode = ThemeMode.light;
    searchResultCount = 15;
    showCompletedBooks = false;
  }

  @override
  void loadFromJson(Map<String, dynamic> data) {
    seedColor = materialColorFromString(data["seedColor"]);
    themeMode = themeModeFromString(data["themeMode"]);
    searchResultCount = data["searchResultCount"];
    showCompletedBooks = data["showCompletedBooks"];
  }

  @override
  Map<String, dynamic> toJson() => {
    "seedColor": seedColorName(),
    "themeMode": themeModeName(),
    "searchResultCount": searchResultCount,
    "showCompletedBooks": showCompletedBooks,
  };

  void setSeedColor(Color seed) {
    seedColor = seed;
    syncToSave();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    syncToSave();
  }

  void setSearchResultCount(int count) {
    searchResultCount = count;
    syncToSave();
  }

  void setShowCompletedBooks(bool show) {
    showCompletedBooks = show;
    syncToSave();
  }

  String seedColorName() {
    if (colorNames.containsKey(seedColor)) {
      return colorNames[seedColor]!;
    }
    return seedColor.toARGB32().toString();
  }

  String themeModeName() {
    return modeNames[themeMode]!;
  }

  static Color materialColorFromString(String colorString) {
    if (colorValues.containsKey(colorString)) {
      return colorValues[colorString]!;
    }
    return Color(int.parse(colorString));
  }

  static ThemeMode themeModeFromString(String modeString) {
    return modeValues[modeString]!;
  }
}

late Directory storageRoot;
late Directory? downloads;

String appVersion = "release_4.5.2";
LibraryData libraryData = LibraryData();
SettingsData settingsData = SettingsData();