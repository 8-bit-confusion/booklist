import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

double luma(Color c) {
  return (0.299 * c.red) + (0.587 * c.green) + (0.114 * c.blue);
}

Color onColor(BuildContext context, Color color) {
  double surfaceLuma = luma(Theme.of(context).colorScheme.surface);
  double onSurfaceLuma = luma(Theme.of(context).colorScheme.onSurface);
  double colorLuma = luma(color);

  double surfaceContrast = (colorLuma - surfaceLuma).abs();
  double onSurfaceContrast = (colorLuma - onSurfaceLuma).abs();

  return surfaceContrast > onSurfaceContrast ?
      Theme.of(context).colorScheme.surface :
      Theme.of(context).colorScheme.onSurface;
}

Directory? getDownloadsDirectoryCustom() {
  if (Platform.isIOS) {
    getApplicationDocumentsDirectory().then((Directory? directory) {
      return directory;
    });
  } else {
    Directory? directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) directory = null;
    return directory;
  }

  return null;
}