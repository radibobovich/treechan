import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';

import '../../provider/page_provider.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    required this.onCloseDrawer,
  });
  final Function onCloseDrawer;
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 40, 0, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) {
                submit();
              },
              decoration: const InputDecoration(
                hintText: "Ссылка или тег доски...",
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.arrow_forward), onPressed: submit)
        ],
      ),
    );
  }

  void submit() {
    try {
      final provider = context.read<PageProvider>();
      provider.addTab(ImageboardSpecific.tryOpenUnknownTabFromLink(
          _controller.text, provider.tabManager.currentTab));
      widget.onCloseDrawer();
    } catch (e) {
      // do nothing
    }
  }

  void showErrorSnackBar() {}
}
