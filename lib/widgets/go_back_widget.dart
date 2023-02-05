import 'package:flutter/material.dart';

/// A cratch.
class GoBackButton extends StatelessWidget {
  const GoBackButton({super.key, required this.onGoBack});
  final Function onGoBack;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        onGoBack();
      },
    );
  }
}
