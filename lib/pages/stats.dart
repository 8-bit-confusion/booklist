import 'package:flutter/material.dart';
import '../pages.dart';

class Stats extends PageContent {
  const Stats({super.key});

  @override
  String title() { return "Statistics"; }

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Coming soon...",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20.0,
                  color: Theme.of(context).colorScheme.primary),
            ),
            Text("Check back in version 5.0!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}