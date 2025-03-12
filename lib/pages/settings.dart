import 'dart:io';

import 'package:booklist/pages/about.dart';
import 'package:booklist/saves.dart';
import 'package:booklist/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../pages.dart';
import 'style.dart';

class Settings extends PageContent {
  const Settings({super.key});

  @override
  String title() { return "Settings"; }

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _searchResultCountKey = GlobalKey();

  final int versionEasterEggTarget = 10;
  int versionEasterEggCounter = 0;
  bool showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text("Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.primary,),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Appearance and style", style: TextStyle(fontWeight: FontWeight.w300,),),
                  subtitle: Text("Color palette · Light & dark mode",
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return const StyleSettings();
                      })
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0,),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: SwitchListTile(
                  inactiveThumbColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(context).colorScheme.secondaryContainer,
                  activeColor: Theme.of(context).colorScheme.secondaryContainer,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  trackOutlineColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
                  secondary: const Icon(Icons.menu_book),
                  title: const Text("Show completed books", style: TextStyle(fontWeight: FontWeight.w300,),),
                  subtitle: Text("Show books you've finished reading in your library page",
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  value: settingsData.showCompletedBooks,
                  onChanged: (bool value) {
                    setState(() { settingsData.setShowCompletedBooks(value); });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0,),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text("Search results", style: TextStyle(fontWeight: FontWeight.w300,),),
                  subtitle: Text("Show first ${settingsData.searchResultCount} results",
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(
                            "Set Search Result Count",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16.0,
                            ),
                          ),
                          content: Form(
                            key: _searchResultCountKey,
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "Result count",
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
                                  int results = int.parse(value).clamp(1, 40);
                                  setState(() { settingsData.setSearchResultCount(results); });
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        )
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0,),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text("Export save data", style: TextStyle(fontWeight: FontWeight.w300,),),
                      subtitle: Text("Export save data to disk as .json file",
                        style: TextStyle(fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 500),
                              content: Row(
                                children: [
                                  Icon(Icons.downloading,
                                    color: Theme.of(context).colorScheme.surface,),
                                  const SizedBox(width: 16.0,),
                                  Text("Saving...", style: TextStyle(
                                    color: Theme.of(context).colorScheme.surface,),),
                                ],
                              ),
                              backgroundColor: Theme.of(context).colorScheme.onSurface,
                            )
                        );

                        String snackBarText;
                        IconData snackBarIcon;

                        String? exportPath = libraryData.export();
                        if (exportPath != null) {
                          snackBarText = "Saved as '$exportPath'.";
                          snackBarIcon = Icons.download_done;
                        } else {
                          snackBarText = "Could not export—downloads folder does not exist.";
                          snackBarIcon = Icons.error;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(snackBarIcon,
                                    color: Theme.of(context).colorScheme.surface,),
                                  const SizedBox(width: 16.0,),
                                  Text(snackBarText, style: TextStyle(
                                    color: Theme.of(context).colorScheme.surface,),),
                                ],
                              ),
                              backgroundColor: Theme.of(context).colorScheme.onSurface,
                            )
                        );
                      },
                    ),
                    Divider(height: 1.0, thickness: 1.0, indent: 56.0, endIndent: 24.0,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.25),),
                    ListTile(
                      leading: const Icon(Icons.upload),
                      title: const Text("Import save data", style: TextStyle(fontWeight: FontWeight.w300,),),
                      subtitle: Text("Load .json save file from disk",
                        style: TextStyle(fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          File importFile = File(result.files.single.path!);
                          libraryData.import(importFile);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.download_done,
                                        color: Theme.of(context).colorScheme.surface,),
                                      const SizedBox(width: 16.0,),
                                      Text("Save data loaded.", style: TextStyle(
                                        color: Theme.of(context).colorScheme.surface,),),
                                    ],
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                                )
                            );
                          }
                        }
                      },
                    ),
                    Divider(height: 1.0, thickness: 1.0, indent: 56.0, endIndent: 24.0,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.25),),
                    ListTile(
                      leading: const Icon(Icons.delete_forever),
                      title: const Text("Clear local save data", style: TextStyle(fontWeight: FontWeight.w300,),),
                      subtitle: Text("Wipe all local save data",
                        style: TextStyle(fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                "Clear local save data",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16.0,
                                ),
                              ),
                              content: Text(
                                "This will delete all local save data, including saved books and reading progress. This action cannot be undone.",
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
                                      Navigator.of(context).pop();
                                      for (FileSystemEntity fileEntity in storageRoot.listSync()) {
                                        if (fileEntity.path.endsWith(LibraryData.dataFileName)) fileEntity.deleteSync();
                                      }

                                      libraryData.syncFromSave();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Local data cleared.", style: TextStyle(
                                              color: Theme.of(context).colorScheme.surface,),),
                                            backgroundColor: Theme.of(context).colorScheme.onSurface,
                                          )
                                      );
                                    }
                                )
                              ],
                            )
                        );
                      },
                    ),
                    Divider(height: 1.0, thickness: 1.0, indent: 56.0, endIndent: 24.0,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.25),),
                    ListTile(
                      leading: const Icon(Icons.replay),
                      title: const Text("Reset preferences", style: TextStyle(fontWeight: FontWeight.w300,),),
                      subtitle: Text("Reset settings to defaults",
                        style: TextStyle(fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                "Reset Preferences",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16.0,
                                ),
                              ),
                              content: Text(
                                "Reset preferences to defaults? This action cannot be undone.",
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
                                    child: Text("RESET",
                                      style: TextStyle(color: Theme.of(context).colorScheme.error,),),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      for (FileSystemEntity fileEntity in storageRoot.listSync()) {
                                        if (fileEntity.path.endsWith(SettingsData.dataFileName)) fileEntity.deleteSync();
                                      }

                                      settingsData.syncFromSave();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Preferences reset.", style: TextStyle(
                                              color: Theme.of(context).colorScheme.surface,),),
                                            backgroundColor: Theme.of(context).colorScheme.onSurface,
                                          )
                                      );
                                    }
                                )
                              ],
                            )
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0,),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("About booklist", style: TextStyle(fontWeight: FontWeight.w300,),),
                  subtitle: Text("App info · About the developer",
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return const About();
                      })
                  ),
                ),
              ),
            ),
            ListTile(
              splashColor: Colors.transparent,
              title: const Text("Version:", style: TextStyle(fontWeight: FontWeight.w300,),),
              subtitle: Text(appVersion,
                style: TextStyle(fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () {
                if (versionEasterEggCounter < versionEasterEggTarget) versionEasterEggCounter++;
                if (versionEasterEggCounter == versionEasterEggTarget) { setState(() {
                  showDebugInfo = !showDebugInfo;
                  versionEasterEggCounter = 0;
                }); }
              },
            ),
          ] + (showDebugInfo && kDebugMode ? <Widget>[
            ListTile(
              title: const Text("Debug Info:",
                style: TextStyle(fontWeight: FontWeight.w300,),),
              subtitle: Text("storageRoot: ${storageRoot.path}\n"
                  "${storageRoot.listSync()
                      .where((FileSystemEntity fileEntity) => fileEntity.path.endsWith(".books"))
                      .map((FileSystemEntity fileEntity) => "\t- ${fileEntity.path.substring(fileEntity.path.lastIndexOf("/"))}\n")
                      .toList().join("")}"
                  "downloadsDirectory: ${getDownloadsDirectoryCustom()!.path}\n"
                  "colorScheme:\n"
                  "\t.onSurface: 0x${Theme.of(context).colorScheme.onSurface.value.toRadixString(16).substring(2)}\n"
                  "\t.primary: 0x${Theme.of(context).colorScheme.primary.value.toRadixString(16).substring(2)}\n"
                  "\t.fadedPrimary: 0x${Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.3)!.value.toRadixString(16).substring(2)}\n"
                  "\t.darkenedSecondary: 0x${Color.lerp(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondaryContainer, 0.75)!.value.toRadixString(16).substring(2)}\n"
                  "\t.secondaryContainer: 0x${Theme.of(context).colorScheme.secondaryContainer.value.toRadixString(16).substring(2)}\n"
                  "\t.surface: 0x${Theme.of(context).colorScheme.surface.value.toRadixString(16).substring(2)}",
                style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ] : []),
        ),
      ),
    );
  }
}