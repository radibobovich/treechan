import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/services/search_service.dart';
import '../../provider/page_provider.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    // required this.onOpen,
    required this.onCloseDrawer,
  });
  // final Function onOpen;
  final Function onCloseDrawer;
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final SearchService searchBarService = SearchService();

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
      context
          .read<PageProvider>()
          .addTab(searchBarService.parseInput(_controller.text));
      widget.onCloseDrawer();
    } catch (e) {
      // do nothing
    }
  }

  void showErrorSnackBar() {}
}
