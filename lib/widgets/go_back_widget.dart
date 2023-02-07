import 'package:flutter/material.dart';
import '../screens/tab_navigator.dart';

/// A cratch.
class GoBackButton extends StatelessWidget {
  const GoBackButton(
      {super.key, required this.onGoBack, required this.currentTab});
  final DrawerTab currentTab;
  final Function onGoBack;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        onGoBack(currentTab);
      },
    );
  }
}
