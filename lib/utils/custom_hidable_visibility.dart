import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

double customHidableVisibility(
    ScrollPosition position, double currentVisibility) {
  const double deltaFactor = 0.04;
  if (position.pixels == 0) {
    return 1;
  }

  /// When user scrolls down
  if (position.userScrollDirection == ScrollDirection.reverse) {
    return (currentVisibility - deltaFactor).clamp(0, 1);
  }

  /// When user scrolls up
  if (position.userScrollDirection == ScrollDirection.forward) {
    return (currentVisibility + deltaFactor).clamp(0, 1);
  }
  return currentVisibility;
}
