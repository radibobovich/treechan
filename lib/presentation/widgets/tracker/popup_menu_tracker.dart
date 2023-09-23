import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopupMenuTracker extends StatelessWidget {
  const PopupMenuTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return <PopupMenuEntry>[
          _getFilterButton(),
          _getIntervalButton(context),
        ];
      },
    );
  }
}

void showPopupMenuTracker(BuildContext context) {
  final RelativeRect rect = RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width - 136, // width of popup menu
      MediaQuery.of(context).size.height - 2 * 48 - 60,
      // 48 is the height of one tile, 60 is approx. height of bottom bars
      0,
      0);
  showMenu(
      context: context, position: rect, items: [_getIntervalButton(context)]);
}

PopupMenuItem<dynamic> _getFilterButton() {
  return const PopupMenuItem(child: FilterSwitch());
}

class FilterSwitch extends StatefulWidget {
  const FilterSwitch({
    super.key,
  });

  @override
  State<FilterSwitch> createState() => _FilterSwitchState();
}

class _FilterSwitchState extends State<FilterSwitch> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final prefs = snapshot.data as SharedPreferences;
            final getAllUpdates = prefs.getBool('getAllUpdates') ?? false;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Все уведомления'),
              value: getAllUpdates,
              onChanged: (value) {
                prefs.setBool('getAllUpdates', !getAllUpdates);
                setState(() {});
              },
            );
          }
          return const SizedBox.shrink();
        });
  }
}

PopupMenuItem<dynamic> _getIntervalButton(BuildContext context) {
  return PopupMenuItem(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: const Text('Интервал обновления'),
    onTap: () => showIntervalDialog(context),
  );
}

showIntervalDialog(BuildContext context) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<Object>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final preferences = snapshot.data as SharedPreferences;
              final interval = preferences.getInt('refreshInterval') ?? 60;
              final TextEditingController controller =
                  TextEditingController(text: interval.toString());
              return AlertDialog(
                title: const Text('Интервал обновления'),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Интервал в секундах',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || int.parse(value) <= 0) {
                        return 'Введите число';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        preferences.setInt(
                            'refreshInterval', int.parse(controller.text));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('ОК'),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          });
    },
  );
}
