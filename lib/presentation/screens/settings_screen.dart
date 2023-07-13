import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';

import 'package:treechan/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: SettingsList(
        applicationType: ApplicationType.both,
        darkTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
          inactiveSubtitleColor: Colors.red,
        ),
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
          titleTextColor: Theme.of(context).textTheme.titleMedium!.color,
        ),
        sections: [
          SettingsSection(
            title: const Text('Интерфейс',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.palette),
                title: const Text('Тема'),
                value: Text(prefs.getString('theme')!),
                onPressed: (context) {
                  showDialog(
                      context: context,
                      builder: (BuildContext bcontext) {
                        final List<String> themes =
                            prefs.getStringList('themes')!;
                        return AlertDialog(
                            contentPadding: const EdgeInsets.all(10),
                            content: ThemesSelector(themes: themes));
                      }).then((value) => setState(() {}));
                },
              ),
            ],
          ),
          SettingsSection(
              title: const Text('Тред',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              tiles: <SettingsTile>[
                SettingsTile.switchTile(
                  leading: const Icon(Icons.expand_more),
                  title: const Text('Ветви постов свернуты по умолчанию'),
                  description: const Text(
                      'Настройка вступит в силу при следующей загрузке треда.'),
                  initialValue: prefs.getBool('postsCollapsed')!,
                  onToggle: (value) {
                    setState(() {
                      prefs.setBool('postsCollapsed', value);
                    });
                  },
                ),
                SettingsTile.switchTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Горизонтальная прокрутка треда'),
                  description: const Text(
                      'Альтернативное отображение треда. Ветви будут уходить вправо сколько угодно. Настройка вступит в силу после повторного открытия вкладки треда.'),
                  initialValue: prefs.getBool('2dscroll')!,
                  onToggle: (value) {
                    setState(() {
                      prefs.setBool('2dscroll', value);
                    });
                  },
                ),
                SettingsTile.switchTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Спойлеры'),
                  description: const Text(
                      'Настройка вступит в силу после того, как пост окажется вне экрана.'),
                  initialValue: prefs.getBool('spoilers')!,
                  onToggle: (value) {
                    setState(() {
                      prefs.setBool('spoilers', value);
                    });
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.download),
                  title: const Text('Место сохранения медиа'),
                  value: Text(getDestinationName(
                      prefs.getString('androidDestinationType')!)),
                  onPressed: (context) {
                    showDialog(
                        context: context,
                        builder: (BuildContext bcontext) {
                          return AlertDialog(
                              contentPadding: const EdgeInsets.all(10),
                              content: DestinationSelector());
                        }).then((value) => setState(() {}));
                  },
                )
              ])
        ],
      ),
    );
  }
}

String getDestinationName(String destination) {
  switch (destination) {
    case 'directoryDownloads':
      return 'Загрузки';
    case 'directoryPictures':
      return 'Галерея';
    case 'directoryDCIM':
      return 'DCIM';
    case 'directoryMovies':
      return 'Movies';
    default:
      return 'Неизвестно';
  }
}

class ThemesSelector extends StatelessWidget {
  const ThemesSelector({
    super.key,
    required this.themes,
  });

  final List<String> themes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.minPositive,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: themes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(themes[index]),
                onTap: () {
                  prefs.setString('theme', themes[index]);
                  theme.add(themes[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class DestinationSelector extends StatelessWidget {
  DestinationSelector({super.key});
  final List<String> destinations = [
    'directoryDownloads',
    'directoryPictures',
    'directoryDCIM',
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.minPositive,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(getDestinationName(destinations[index])),
                onTap: () {
                  prefs.setString(
                      'androidDestinationType', destinations[index]);
                  Navigator.pop(context);
                },
              );
            },
          )
        ],
      ),
    );
  }
}
