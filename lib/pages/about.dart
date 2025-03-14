import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../saves.dart';
import '../pages.dart';

class About extends PageContent {
  const About({super.key});

  @override
  String title() { return "About"; }

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text("About booklist",
          style: TextStyle(color: Theme.of(context).colorScheme.primary,),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: max(0, 96.0 - (MediaQuery.of(context).viewPadding.top + kToolbarHeight)),),
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
                  const Text("App info", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18.0,),),
                  Divider(height: 8.0, color: Theme.of(context).colorScheme.inversePrimary,),
                  Text(
                    "Version: $appVersion\n\n"
                    "Backwards compatibility: all saves created in booklist 4.0.0 "
                    "or later are compatible with the current version.\n\n"
                    "© 2025 prettytoastie",
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
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
                  const Text("About the developer", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18.0,),),
                  Divider(height: 8.0, color: Theme.of(context).colorScheme.inversePrimary,),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 48.0,
                      width: 48.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset("images/miffy-pfp.jpg"),
                    ),
                    title: const Text("prettytoastie", style: TextStyle(fontWeight: FontWeight.w300,),),
                    subtitle: Text("(she/her)", style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary,),),
                  ),
                  Text(
                    "Howdy hey! I'm toast :3\n\n"
                    "I made this app because I like reading, and I wanted a place to keep track of my books "
                    "(that wasn't Goodreads). It was originally designed with just the features I wanted, so "
                    "if you think it's missing something, let me know!\n\nOther than that, "
                    "I hope you enjoy and find it as useful as I have! I worked very hard on it ^u^",
                    style: TextStyle(fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 16.0),
                  Divider(height: 8.0, color: Theme.of(context).colorScheme.inversePrimary,),
                  TextButton(
                    child: Row(
                      children: <Widget>[
                        Image.network("https://storage.ko-fi.com/cdn/logomarkLogo.png", width: 32.0, height: 32.0,),
                        const SizedBox(width: 16.0),
                        Text("Buy me a coffee", style: TextStyle(fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.primary,),),
                      ],
                    ),
                    onPressed: () async { await launchUrl(Uri.parse("https://ko-fi.com/prettytoastie")); },
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}