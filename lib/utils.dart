import 'package:flutter/material.dart';

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