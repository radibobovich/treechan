import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/page_provider.dart';
import '../../../domain/models/tab.dart';

/// A cratch.
class GoBackButton extends StatelessWidget {
  const GoBackButton({super.key, required this.currentTab});
  final DrawerTab currentTab;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        context.read<PageProvider>().goBack();
      },
    );
  }
}
