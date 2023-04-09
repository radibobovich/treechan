import 'package:flutter/material.dart';

import '../services/search_bar_service.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    required this.onOpen,
    required this.onCloseDrawer,
  });
  final Function onOpen;
  final Function onCloseDrawer;
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final SearchBarService searchBarService = SearchBarService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 40, 0, 10),
      child: Row(
        children: [
          Expanded(
            // TODO: make enter key work
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Ссылка или тег доски...",
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                try {
                  widget.onOpen(searchBarService.parseInput(_controller.text));
                  widget.onCloseDrawer();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // TODO: make it appear above drawer
                    const SnackBar(
                      content: Text("Неверная ссылка"),
                      behavior: SnackBarBehavior.floating,
                      elevation: 0,
                    ),
                  );
                }
              })
        ],
      ),
    );
  }
}