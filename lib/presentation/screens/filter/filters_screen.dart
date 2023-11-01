// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/presentation/bloc/filters_cubit.dart';
import 'package:treechan/utils/constants/enums.dart';

class FiltersScreen extends StatelessWidget {
  const FiltersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.read<FiltersCubit>().boardTag == null
            ? const Text('Фильтры')
            : Text('Фильтры - /${context.read<FiltersCubit>().boardTag}/'),
        actions: [
          IconButton(
              onPressed: () => context.read<FiltersCubit>().toggleAll(true),
              icon: const Icon(Icons.done_all)),
          IconButton(
              onPressed: () => context.read<FiltersCubit>().toggleAll(false),
              icon: const Icon(Icons.remove_done)),
          IconButton(
            onPressed: () => showDeleteAllDialog(context),
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: BlocBuilder<FiltersCubit, FiltersState>(
        builder: (context, state) {
          if (state is FiltersLoaded) {
            return ListView.builder(
              itemCount: state.filters.length,
              itemBuilder: (context, index) {
                final filter = state.filters[index];
                return FilterTile(filter: filter);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/filter_edit', arguments: {
            'filter': null,
            'add': context.read<FiltersCubit>().add,
            'getBoards': context.read<FiltersCubit>().getBoards,
            'currentBoard': context.read<FiltersCubit>().boardTag,
          });
        },
        child: Icon(
          Icons.add,
          color: context.theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

class FilterTile extends StatelessWidget {
  const FilterTile({super.key, required this.filter});
  final Filter filter;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ObjectKey(filter),
      leading: Switch(
          value: filter.enabled,
          onChanged: (value) =>
              context.read<FiltersCubit>().toggle(filter.id!)),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(filter.name, overflow: TextOverflow.ellipsis),
            const SizedBox.square(dimension: 5),
            Text('Паттерн: ${filter.pattern}', overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      subtitle: filter is FilterWithBoards
          ? Text(
              (filter as FilterWithBoards).boardsEnumeration,
              style: TextStyle(
                  color: context.theme.textTheme.bodySmall?.color,
                  overflow: TextOverflow.ellipsis),
              maxLines: 2,
            )
          : null,
      trailing: Wrap(children: [
        Column(
          children: [
            Text(filter.imageboard,
                style:
                    TextStyle(color: context.theme.textTheme.bodySmall?.color)),
            IconButton(
                onPressed: () =>
                    context.read<FiltersCubit>().remove(filter.id!),
                icon: const Icon(Icons.delete_forever))
          ],
        ),
      ]),
      onTap: () async {
        Navigator.of(context).pushNamed('/filter_edit', arguments: {
          'filter': filter is FilterWithBoards
              ? filter
              : await context.read<FiltersCubit>().getFilterWithBoards(filter),
          'update': context.read<FiltersCubit>().update,
          'getBoards': context.read<FiltersCubit>().getBoards,
        });
      },
    );
  }
}

void showDeleteAllDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (builderContext) {
      return AlertDialog(
        title: const Text('Очистить фильтры?'),
        content: Text(
            context.read<FiltersCubit>().displayMode == FiltersDisplayMode.all
                ? 'Это действие удалит фильтры для всех досок.'
                : 'Это действие удалит фильтры только для этой доски.'),
        contentPadding: const EdgeInsets.fromLTRB(24, 15, 24, 0),
        actions: [
          TextButton(
              onPressed: () {
                context.read<FiltersCubit>().removeAll();
                Navigator.pop(builderContext);
              },
              child: Text(
                'Очистить',
                style: TextStyle(color: context.colors.boldText),
              )),
          TextButton(
              onPressed: () => Navigator.pop(builderContext),
              child: const Text('Отмена')),
        ],
      );
    },
  );
}
