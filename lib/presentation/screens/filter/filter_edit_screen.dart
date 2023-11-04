import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/core/board.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/presentation/widgets/shared/no_connection_placeholder.dart';
import 'package:treechan/utils/constants/enums.dart';

/// A screen to edit existing filter or to create a new one.
///
/// [add] function must be provided in case of creating new filter.
///
/// [update] function must be provided in case of editing existing filter.
class FilterEditScreen extends StatefulWidget {
  const FilterEditScreen(
      {super.key,
      required this.filter,
      required this.add,
      required this.update,
      required this.getBoards,
      this.currentBoard});
  final FilterWithBoards? filter;
  final String? currentBoard;
  final Function(FilterWithBoards)? add;
  final Function(FilterWithBoards, FilterWithBoards)? update;
  final Function(Imageboard) getBoards;
  @override
  State<FilterEditScreen> createState() => _FilterEditScreenState();
}

class _FilterEditScreenState extends State<FilterEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool? patternMatched;
  bool caseSensitive = false;
  late Imageboard imageboard;
  late TextEditingController selectedBoardsController;
  @override
  void initState() {
    imageboard = imageboardFromString(
        widget.filter?.imageboard ?? Imageboard.dvach.name);
    selectedBoardsController = TextEditingController(
        text: widget.filter == null
            ? widget.currentBoard == null
                ? null
                : '${widget.currentBoard}, '
            : '${widget.filter!.boardsEnumeration}, ');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтр'),
        actions: [
          IconButton(
              onPressed: () async {
                final bool valid =
                    _formKey.currentState?.saveAndValidate() ?? false;
                if (!valid) return;

                final Map<String, dynamic> values =
                    _formKey.currentState!.value;
                final List<String> selectedBoards =
                    (values['boards']! as String)
                        .replaceAll(' ', '')
                        .split(',');
                final List<String> cleanedBoards = selectedBoards
                  ..removeWhere((element) => element.isEmpty);
                final Set<String> boardsSet = cleanedBoards.toSet();
                final newFilter = FilterWithBoards(
                  boardsSet.toList(),
                  id: widget.filter?.id,
                  enabled: widget.filter?.enabled ?? true,
                  imageboard: values['imageboard'],
                  name: values['name'] ?? '',
                  pattern: values['pattern'],
                  caseSensitive: values['case_sensitive'],
                );

                if (widget.filter == null) {
                  widget.add!(newFilter);
                } else {
                  widget.update!(widget.filter!, newFilter);
                }
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.done))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FormBuilder(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Название',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    FormBuilderTextField(
                        name: 'name', initialValue: widget.filter?.name ?? ''),
                    const SizedBox.square(
                      dimension: 14,
                    ),
                    const Text(
                      'Паттерн',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    FormBuilderTextField(
                      name: 'pattern',
                      decoration: const InputDecoration(
                          hintText: 'Например: Лесополоса'),
                      initialValue: widget.filter?.pattern,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (pattern) {
                        setState(() {
                          if (pattern == null || pattern.isEmpty) {
                            return;
                          }
                          final testString = _formKey
                              .currentState?.fields['pattern_test']?.value;
                          if (testString == null) return;

                          final regExp =
                              RegExp(pattern, caseSensitive: caseSensitive);
                          patternMatched = regExp.hasMatch(testString);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Не указан паттерн';
                        }
                        return null;
                      },
                    ),
                    FormBuilderCheckbox(
                      name: 'case_sensitive',
                      title: const Text('Учитывать регистр'),
                      initialValue: false,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          caseSensitive = value;
                          final testString = _formKey
                              .currentState?.fields['pattern_test']?.value;
                          final pattern =
                              _formKey.currentState?.fields['pattern']?.value;
                          if (pattern == null || testString == null) return;

                          final regExp =
                              RegExp(pattern, caseSensitive: caseSensitive);
                          patternMatched = regExp.hasMatch(testString);
                        });
                      },
                    ),
                    const SizedBox.square(
                      dimension: 14,
                    ),
                    Row(
                      children: [
                        const Text(
                          'Проверка паттерна',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        patternMatched == null
                            ? Text(
                                'Тестовая строка пуста',
                                style: TextStyle(
                                    color: context
                                        .theme.textTheme.bodySmall?.color),
                              )
                            : patternMatched!
                                ? const Text('Паттерн обнаружен',
                                    style: TextStyle(color: Colors.green))
                                : const Text('Паттерн не обнаружен',
                                    style: TextStyle(color: Colors.red))
                      ],
                    ),
                    FormBuilderTextField(
                      name: 'pattern_test',
                      decoration: const InputDecoration(
                          hintText: 'Введите текст для проверки'),
                      onChanged: (text) {
                        setState(() {
                          if (text == null || text.isEmpty) {
                            patternMatched = null;
                            return;
                          }

                          final pattern =
                              _formKey.currentState?.fields['pattern']?.value;
                          if (pattern == null) return;

                          final regExp = RegExp(r"" + pattern,
                              caseSensitive: caseSensitive);
                          patternMatched = regExp.hasMatch(text);
                        });
                      },
                    ),
                    const SizedBox.square(
                      dimension: 14,
                    ),
                    const Text(
                      'Имиджборд',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    FormBuilderDropdown(
                      name: 'imageboard',
                      initialValue:
                          widget.filter?.imageboard ?? Imageboard.dvach.name,
                      items: getOriginalImageboards().map((e) {
                        return DropdownMenuItem(
                          value: e.name,
                          child: Text(e.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value == null) return;
                          imageboard = imageboardFromString(value);
                        });
                      },
                    ),
                    const SizedBox.square(
                      dimension: 14,
                    ),
                    const Text(
                      'Доски',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    FormBuilderTextField(
                      name: 'boards',
                      decoration: const InputDecoration(
                          hintText:
                              'Добавьте ANY для применения ко всем доскам'),
                      controller: selectedBoardsController,
                      validator: (value) {
                        final RegExp pattern = RegExp(r'^[A-Za-z, ]+$');
                        if (value == null ||
                            value.isEmpty ||
                            !pattern.hasMatch(value)) {
                          return 'Неверно указаны доски';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BoardsSelector(
                key: ObjectKey(imageboard),
                imageboard: imageboard,
                getBoards: widget.getBoards,
                addBoard: (tag) {
                  setState(() {
                    selectedBoardsController.text += '$tag, ';
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BoardsSelector extends StatefulWidget {
  const BoardsSelector(
      {super.key,
      required this.imageboard,
      required this.getBoards,
      required this.addBoard});
  final Imageboard imageboard;
  final Function(Imageboard) getBoards;
  final Function(String tag) addBoard;
  @override
  State<BoardsSelector> createState() => _BoardsSelectorState();
}

class _BoardsSelectorState extends State<BoardsSelector> {
  late Future<List<Board>> boardsFuture;
  List<Board> boards = [];
  List<Board> boardsFound = [];
  bool isError = false;
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadBoards();
  }

  void loadBoards() {
    boardsFuture = widget.getBoards(widget.imageboard);
    boardsFuture.then((value) {
      setState(() {
        boards = value;
        boardsFound = boards;
        isError = false;
      });
    }, onError: (Object obj) {
      setState(() {
        isError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Поиск по доскам',
            ),
            onChanged: (value) {
              if (value.isEmpty) boardsFound = boards;
              setState(() {
                boardsFound = boards
                    .where((board) =>
                        board.name
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                        board.id.contains(value.toLowerCase()))
                    .toList();
                debugPrint(boardsFound.toString());
              });
            },
          ),
        ),
        isError
            ? NoConnectionPlaceholder(onRetry: loadBoards)
            : SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: boardsFound.length,
                  itemBuilder: (context, index) {
                    final board = boardsFound[index];
                    return ListTile(
                      key: ObjectKey(board),
                      title: Text(board.name),
                      subtitle: Text('/${board.id}/'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => widget.addBoard(board.id),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
