import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constants/enums.dart';
import '../../bloc/board_list_bloc.dart';
import '../../screens/page_navigator.dart';

class NormalAppBar extends StatelessWidget {
  final bool allowReorder;
  const NormalAppBar({
    super.key,
    required this.allowReorder,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Доски'),
      leading: const DrawerLeadingButton(),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            BlocProvider.of<BoardListBloc>(context)
                .add(SearchQueryChangedEvent(""));
          },
        ),
        allowReorder ? const IconCompleteReorder() : const IconRefreshBoards()
      ],
      bottom: TabBar(
        tabs: const [Tab(text: 'Основные'), Tab(text: 'Пользовательские')],
        indicatorColor: Theme.of(context).scaffoldBackgroundColor,
        // TODO: fix theme color for night mode
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
              hintText: ' Поиск',
              hintStyle: TextStyle(color: Colors.white70),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
          onChanged: (query) {
            BlocProvider.of<BoardListBloc>(context)
                .add(SearchQueryChangedEvent(query));
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            BlocProvider.of<BoardListBloc>(context).add(LoadBoardListEvent());
          },
        ));
  }
}

class DrawerLeadingButton extends StatelessWidget {
  const DrawerLeadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        openDrawer();
      },
    );
  }
}

class IconCompleteReorder extends StatelessWidget {
  const IconCompleteReorder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.done),
      onPressed: () {
        BlocProvider.of<BoardListBloc>(context)
            .add(EditFavoritesEvent(action: FavoriteListAction.toggleReorder));
      },
    );
  }
}

class IconRefreshBoards extends StatelessWidget {
  const IconRefreshBoards({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        BlocProvider.of<BoardListBloc>(context).add(RefreshBoardListEvent());
      },
    );
  }
}
