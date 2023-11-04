import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:treechan/main.dart';
import 'package:treechan/utils/constants/enums.dart';

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
            title: const Text('Доски',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.visibility_off),
                title: const Text('Автоскрытие'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onPressed: (context) {
                  Navigator.pushNamed(context, '/filters', arguments: {
                    'displayMode': FiltersDisplayMode.all,
                  });
                },
              )
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
                  leading: const Icon(Icons.texture),
                  title: const Text('Спойлеры'),
                  description: const Text(
                      'Настройка вступит в силу после того, как пост окажется вне экрана.'),
                  initialValue: prefs.getBool('spoilers')!,
                  onToggle: (value) {
                    setState(() {
                      prefs.setBool('spoilers', value).then((value) async {
                        prefs = await SharedPreferences.getInstance();
                      });
                    });
                  },
                ),

                SettingsTile.switchTile(
                  leading: const Icon(Icons.view_list),
                  title: const Text(
                      'Отображать список открытых вкладок в нижней части шторки'),
                  description: const Text(
                      'Облегчает доступ к вкладкам при управлении одной рукой. Настройка вступит в силу при следующем открытии шторки.'),
                  initialValue: prefs.getBool('bottomDrawerTabs')!,
                  onToggle: (value) {
                    setState(() {
                      prefs.setBool('bottomDrawerTabs', value);
                    });
                  },
                ),
                SettingsTile.switchTile(
                  leading: const Icon(Icons.fiber_new),
                  title: const Text(
                      'Отображать кнопку "Показать" в уведомлении о загрузке новых постов'),
                  initialValue:
                      prefs.getBool('showSnackBarActionOnThreadRefresh')!,
                  onToggle: (value) {
                    setState(() {
                      prefs.setBool('showSnackBarActionOnThreadRefresh', value);
                    });
                  },
                ),
                // SettingsTile.navigation(
                //   leading: const Icon(Icons.download),
                //   title: const Text('Место сохранения медиа'),
                //   value: Text(getDestinationName(
                //       prefs.getString('androidDestinationType')!)),
                //   onPressed: (context) {
                //     showDialog(
                //         context: context,
                //         builder: (BuildContext bcontext) {
                //           return AlertDialog(
                //               contentPadding: const EdgeInsets.all(10),
                //               content: DestinationSelector());
                //         }).then((value) => setState(() {}));
                //   },
                // )
              ])
        ],
      ),
    );
  }
}

// String getDestinationName(String destination) {
//   switch (destination) {
//     case 'directoryDownloads':
//       return 'Загрузки';
//     case 'directoryPictures':
//       return 'Галерея';
//     case 'directoryDCIM':
//       return 'DCIM';
//     case 'directoryMovies':
//       return 'Movies';
//     default:
//       return 'Неизвестно';
//   }
// }

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

// class DestinationSelector extends StatelessWidget {
//   DestinationSelector({super.key});
//   final List<String> destinations = [
//     'directoryDownloads',
//     'directoryPictures',
//     'directoryDCIM',
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.minPositive,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListView.builder(
//             shrinkWrap: true,
//             itemCount: destinations.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(getDestinationName(destinations[index])),
//                 onTap: () {
//                   prefs.setString(
//                       'androidDestinationType', destinations[index]);
//                   Navigator.pop(context);
//                 },
//               );
//             },
//           )
//         ],
//       ),
//     );
//   }
// }
