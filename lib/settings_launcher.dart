import 'package:flutter/material.dart';

import 'pages/settings.dart';

class SettingsLauncher extends StatelessWidget {
  final Widget body;
  final bool active;

  const SettingsLauncher({
    super.key,
    required this.body,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    return active ? Stack(
      children: [
        body,
        AppBar(
          forceMaterialTransparency: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const Settings();
                    })
                );
              },
            )
          ],
        ),
      ]
    ) : body;
  }
}