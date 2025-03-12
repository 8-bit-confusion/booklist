import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'saves.dart';
import 'pages.dart';

import 'pages/library.dart';
import 'pages/scan_isbn.dart';
import 'pages/search.dart';
import 'pages/stats.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getApplicationDocumentsDirectory().then((Directory value) {
    storageRoot = value;
    runApp(const App());
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsData,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Booklist',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingsData.seedColor,
              dynamicSchemeVariant: DynamicSchemeVariant.neutral,
            ),
            useMaterial3: true,
            fontFamily: "Noto Sans",
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingsData.seedColor,
              brightness: Brightness.dark,
              dynamicSchemeVariant: DynamicSchemeVariant.neutral,
            ),
            useMaterial3: true,
            fontFamily: "Noto Sans",
          ),
          themeMode: settingsData.themeMode,
          home: const AppRoot(),
        );
      },
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int currentPage = 0;
  List<PageContent> destinationPages = const <PageContent>[
    Library(),
    Search(),
    ScanISBN(),
    Stats(),
  ];

  List<int> topLevelNavigationQueue = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: topLevelNavigationQueue.isEmpty,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          setState(() { currentPage = topLevelNavigationQueue.removeLast(); });
        }
      },
      child: Scaffold(
        body: destinationPages[currentPage],
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentPage,
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.library_books), label: "Library"),
            NavigationDestination(icon: Icon(Icons.search), label: "Search"),
            NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: "Scan ISBN"),
            NavigationDestination(icon: Icon(Icons.stacked_line_chart), label: "Stats"),
          ],
          onDestinationSelected: (int i) {
            setState(() {
              topLevelNavigationQueue.add(currentPage);
              currentPage = i;
            });
          },
        ),
      ),
    );
  }
}
