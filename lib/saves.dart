import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

enum SortMethod {
  custom,
  recent,
  title,
  author,
}

enum TimeSpan {
  week,
  month,
  year,
}

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

class ReadingUpdate {
  final DateTime timestamp;
  final int pages;
  final String id;
  final int bookCompletions;

  ReadingUpdate({
    required this.timestamp,
    required this.pages,
    required this.id,
    required this.bookCompletions,
  });

  ReadingUpdate.fromJson(Map<String, dynamic> data) : this(
    timestamp: DateTime.parse(data["timestamp"]),
    pages: data["pages"],
    id: data["id"],
    bookCompletions: data["bookCompletions"],
  );

  Map<String, dynamic> toJson() => {
    "timestamp": timestamp.toIso8601String(),
    "pages": pages,
    "id": id,
    "bookCompletions": bookCompletions,
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
    setDefaults();
    if (dataFile.existsSync()) {
      loadFromJson(jsonDecode(dataFile.readAsStringSync()));
    } else {
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
  late Map<String, DateTime> readTimestamps;

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
    readTimestamps = {};
  }

  @override
  void loadFromJson(Map<String, dynamic> data) {
    if (data["library"] != null) library = data["library"].map<String>((dynamic value) => value.toString()).toList();
    if (data["libraryItems"] != null) libraryItems = data["libraryItems"].map<String, Item>((String key, dynamic value) => MapEntry(key, Item.fromJson(value)));
    if (data["libraryProgress"] != null) libraryProgress = data["libraryProgress"].map<String, int>((String key, dynamic value) => MapEntry(key, value as int));
    if (data["readTimestamps"] != null) readTimestamps = data["readTimestamps"].map<String, DateTime>((String key, dynamic value) => MapEntry(key, DateTime.parse(value)));
  }

  @override
  Map<String, dynamic> toJson() => {
    "library": library,
    "libraryItems": libraryItems.map((String key, Item value) => MapEntry(key, value.toJson())),
    "libraryProgress": libraryProgress.map((String key, int value) => MapEntry(key, value)),
    "readTimestamps": readTimestamps.map((String key, DateTime value) => MapEntry(key, value.toIso8601String())),
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

  List<Item> items() => library
      .map((String id) => libraryItems[id]!)
      .toList();

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
    if (!libraryProgress.containsKey(item.id)) libraryProgress[item.id] = 0;
    return libraryProgress[item.id]!;
  }

  DateTime getReadTimestamp(Item item) {
    if (!readTimestamps.containsKey(item.id)) readTimestamps[item.id] = DateTime.fromMillisecondsSinceEpoch(0);
    return readTimestamps[item.id]!;
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
    if (!settingsData.showCompletedBooks) {
      // ensure we aren't moving our incomplete books past our hidden completed books
      endIndex = endIndex.clamp(0, incompleteItemCount());
    }
    int offset = startIndex < endIndex ? -1 : 0;
    library.insert(endIndex + offset, library.removeAt(startIndex));
    syncToSave();
  }

  void setProgress(Item item, int newProgress) {
    libraryProgress[item.id] = newProgress;
    if (newProgress == item.pageCount) {
      // keep completed books after incomplete books
      library.insert(incompleteItemCount(), library.removeAt(library.indexOf(item.id)));
    }
    syncToSave();
  }

  void setReadTimestamp(Item item, DateTime newTimestamp) {
    readTimestamps[item.id] = newTimestamp;
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
  late SortMethod sortMethod;
  late TimeSpan timeSpan;
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

  static Map<SortMethod, String> methodNames = {
    SortMethod.custom: "Custom",
    SortMethod.recent: "Most recent",
    SortMethod.title: "Title (A-Z)",
    SortMethod.author: "Author (A-Z)",
  };

  static Map<String, SortMethod> methodValues = Map.fromIterables(methodNames.values, methodNames.keys);

  static Map<SortMethod, int Function(Item, Item)> methodImplementation = {
    SortMethod.custom: (Item a, Item b) => 0,
    SortMethod.recent: (Item a, Item b) => -libraryData.getReadTimestamp(a).compareTo(libraryData.getReadTimestamp(b)),
    SortMethod.title: (Item a, Item b) => a.title.compareTo(b.title),
    SortMethod.author: (Item a, Item b) => a.authors.compareTo(b.authors),
  };

  static Map<TimeSpan, String> spanNames = {
    TimeSpan.week: "Week",
    TimeSpan.month: "Month",
    TimeSpan.year: "Year",
  };

  static Map<String, TimeSpan> spanValues = Map.fromIterables(spanNames.values, spanNames.keys);

  static Map<TimeSpan, List<String>> spanTitles = {
    TimeSpan.week: ["M", "T", "W", "T", "F", "S", "S"],
    TimeSpan.month: List<String>.generate(31, (i) => (i + 1).toString()),
    TimeSpan.year: ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"],
  };

  SettingsData() {
    dataFile = File("${storageRoot.path}/$dataFileName");
    syncFromSave();
  }

  @override
  void setDefaults() {
    seedColor = Colors.amber;
    themeMode = ThemeMode.light;
    sortMethod = SortMethod.custom;
    timeSpan = TimeSpan.week;
    searchResultCount = 15;
    showCompletedBooks = false;
  }

  @override
  void loadFromJson(Map<String, dynamic> data) {
    if (data["seedColor"] != null) seedColor = materialColorFromString(data["seedColor"]);
    if (data["themeMode"] != null) themeMode = modeValues[data["themeMode"]]!;
    if (data["sortMethod"] != null) sortMethod = methodValues[data["sortMethod"]]!;
    if (data["timeSpan"] != null) timeSpan = spanValues[data["timeSpan"]]!;
    if (data["searchResultCount"] != null) searchResultCount = data["searchResultCount"];
    if (data["showCompletedBooks"] != null) showCompletedBooks = data["showCompletedBooks"];
  }

  @override
  Map<String, dynamic> toJson() => {
    "seedColor": seedColorName(),
    "themeMode": modeNames[themeMode]!,
    "sortMethod": methodNames[sortMethod]!,
    "timeSpan": spanNames[timeSpan]!,
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

  void setSortMethod(SortMethod method) {
    sortMethod = method;
    syncToSave();
  }

  void setTimeSpan(TimeSpan span) {
    timeSpan = span;
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

  static Color materialColorFromString(String colorString) {
    if (colorValues.containsKey(colorString)) {
      return colorValues[colorString]!;
    }
    return Color(int.parse(colorString));
  }
}

class StatsData extends SyncedData {
  late List<ReadingUpdate> readingUpdates;

  static const String dataFileName = "statsData.books";

  StatsData() {
    dataFile = File("${storageRoot.path}/$dataFileName");
    syncFromSave();
  }

  @override
  void setDefaults() {
    readingUpdates = [];
  }

  @override
  void loadFromJson(Map<String, dynamic> data) {
    if (data["readingUpdates"] != null) readingUpdates = data["readingUpdates"].map<ReadingUpdate>((dynamic value) => ReadingUpdate.fromJson(value)).toList();
  }

  @override
  Map<String, dynamic> toJson() => {
    "readingUpdates": readingUpdates.map<Map<String, dynamic>>((ReadingUpdate value) => value.toJson()).toList(),
  };

  void add(ReadingUpdate update) {
    readingUpdates.add(update);
    syncToSave();
  }
}

late Directory storageRoot;
late Directory? downloads;

late String appVersion;
String appVersionPrefix = "indev_";

LibraryData libraryData = LibraryData();
SettingsData settingsData = SettingsData();
StatsData statsData = StatsData();