import 'package:flutter/material.dart';

import '../saves.dart';
import '../utils.dart';
import '../pages.dart';

class StyleSettings extends PageContent {
  const StyleSettings({super.key});

  @override
  String title() { return "StyleSettings"; }

  @override
  State<StyleSettings> createState() => _StyleSettingsState();
}

class _StyleSettingsState extends State<StyleSettings> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text("Appearance and style",
          style: TextStyle(color: Theme.of(context).colorScheme.primary,),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 72.0),
              child: Container(
                height: 334,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [BoxShadow(
                    blurRadius: 16.0,
                    offset: const Offset(0.0, 8.0),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
                  )],
                ),
                clipBehavior: Clip.antiAlias,
                child: Scaffold(
                  body: Column(
                    children: <Widget>[
                      Container(height: 24.0, color: Theme.of(context).colorScheme.primary,),
                      Container(height: 24.0, color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.3),),
                      Container(height: 24.0, color: Color.lerp(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondaryContainer, 0.75),),
                      Expanded(child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          const Text("Demo text",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.0,),),
                          Text("Demo text",
                            style: TextStyle(color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w400, fontSize: 20.0,),),
                        ],),),
                      ),),
                      Expanded(child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Demo text",
                              style: TextStyle(color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w400, fontSize: 20.0,),),
                            Text("Demo text",
                              style: TextStyle(color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Theme.of(context).colorScheme.onSurface, 0.3),
                                fontWeight: FontWeight.w400, fontSize: 20.0,),),
                          ],),),
                      ),),
                    ],
                  ),
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: currentPage,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                    height: 64.0,
                    destinations: const <Widget>[
                      NavigationDestination(icon: Icon(Icons.image), label: "Library"),
                      NavigationDestination(icon: Icon(Icons.image), label: "Library"),
                    ],
                    onDestinationSelected: (int i) {
                      setState(() { currentPage = i; });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0,),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                border: Border.fromBorderSide(BorderSide(
                  color: Theme.of(context).colorScheme.inversePrimary,
                )),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Color palette", style: TextStyle(fontWeight: FontWeight.w300,),),
                  Text(settingsData.seedColorName(), style: TextStyle(fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,),),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Colors.primaries.length - 2,
                    itemBuilder: (BuildContext context, int index) {
                      Color thisColor = Colors.primaries.reversed.toList().sublist(2)[index];
                      double selectOutlineWidth = 2.0;

                      return Center(
                        child: Container(
                          width: 32.0 + (2 * selectOutlineWidth),
                          height: 32.0 + (2 * selectOutlineWidth),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16.0 + selectOutlineWidth)),
                            color: settingsData.seedColor == thisColor ?
                                Theme.of(context).colorScheme.onSurface :
                                Theme.of(context).colorScheme.surface
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 32.0,
                              height: 32.0,
                              child: FilledButton(
                                style: ButtonStyle(
                                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                                  backgroundColor: WidgetStatePropertyAll(ColorScheme.fromSeed(
                                      seedColor: thisColor,
                                      dynamicSchemeVariant: DynamicSchemeVariant.neutral
                                  ).secondaryContainer,),
                                ),
                                onPressed: () {
                                  setState(() { settingsData.setSeedColor(thisColor); });
                                },
                                child: settingsData.seedColor == thisColor ? Icon(
                                  Icons.check,
                                  color: onColor(context, thisColor),
                                ) : Container(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0,),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                border: Border.fromBorderSide(BorderSide(
                  color: Theme.of(context).colorScheme.inversePrimary,
                )),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Theme", style: TextStyle(fontWeight: FontWeight.w300,),),
                  Column(
                    children: <Widget>[
                      RadioListTile(
                        value: ThemeMode.light,
                        groupValue: settingsData.themeMode,
                        dense: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Light", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,),),
                            const Icon(Icons.light_mode),
                          ],
                        ),
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            setState(() { settingsData.setThemeMode(value); });
                          }
                        },
                      ),
                      RadioListTile(
                        value: ThemeMode.dark,
                        groupValue: settingsData.themeMode,
                        dense: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Dark", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,),),
                            const Icon(Icons.dark_mode),
                          ],
                        ),
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            setState(() { settingsData.setThemeMode(value); });
                          }
                        },
                      ),
                      RadioListTile(
                        value: ThemeMode.system,
                        groupValue: settingsData.themeMode,
                        dense: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Sync with phone", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,),),
                            const Icon(Icons.sync),
                          ],
                        ),
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            setState(() { settingsData.setThemeMode(value); });
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}