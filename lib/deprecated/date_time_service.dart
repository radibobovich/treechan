import 'package:intl/intl.dart';

class DateTimeService {
  DateTimeService({required this.dateRaw}) {
    _parse();
  }
  final String dateRaw;

  late DateTime? date;

  void _parse() {
    try {
      List<String> daysOfWeek = [
        'Пнд',
        'Втр',
        'Срд',
        'Чтв',
        'Птн',
        'Суб',
        'Вск'
      ];
      List<String> parts = dateRaw.split(' ');
      if (parts[0].contains(RegExp(r'[0-9]')) &&
          daysOfWeek.contains(parts[1])) {
        // 19/03/23 Пнд 13:45:30
        date = _parseModernDateString(dateRaw);
      } else if (daysOfWeek.contains(parts[0])) {
        // Пнд 27 Июн 2011 11:21:54
        date = _parseOldDateString(dateRaw);
      } else {
        // 06:32:22 Морндас, 3-й Руки дождя
        // 22:20:11 Лордас, 2-й день Высокого солнца
        date = _parseSkyrimDateString(dateRaw);
      }
    } catch (e) {
      date = null;
    }
  }

  DateTime _parseModernDateString(String dateRaw) {
    // 19/03/23 Пнд 13:45:30
    List<String> parts = dateRaw.split(' ');
    List<String> dateParts = parts[0].split('/');
    List<String> timeParts = parts[2].split(':');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]) + 2000;
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    return DateTime(year, month, day, hour, minute, second);
  }

  DateTime _parseOldDateString(String dateRaw) {
    // Пнд 27 Июн 2011 11:21:54
    List<String> parts = dateRaw.split(' ');
    List<String> dateParts = [parts[1], parts[2], parts[3]];
    List<String> timeParts = parts[4].split(':');
    int day = int.parse(dateParts[0]);
    int month = _parseMonth(dateParts[1]);
    int year = int.parse(dateParts[2]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);
    return DateTime(year, month, day, hour, minute, second);
  }

  DateTime _parseSkyrimDateString(String dateString) {
    // 06:32:22 Морндас, 3-й Руки дождя
    // 22:20:11 Лордас, 2-й день Высокого солнца

    List<String> parts = dateString.split(' ');
    parts.removeAt(1); // remove day of week
    // 06:32:22 3-й Руки дождя
    // 22:20:11 2-й день Высокого солнца

    if (parts[2] == 'день') {
      parts.removeAt(2); // remove 'день'
    }
    // 06:32:22 3-й Руки дождя
    // 22:20:11 2-й Высокого солнца

    List<String> timeParts = parts[0].split(':');
    String dayOfMonthString = parts[1].split('-')[0];
    String monthString = '${parts[2]} ${parts[3]}';

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    int dayOfMonth = int.parse(dayOfMonthString);
    int month = _parseSkyrimMonth(monthString);

    return DateTime(1970, month, dayOfMonth, hour, minute, second);
  }

  int _parseSkyrimMonth(String monthString) {
    List<String> monthStrings = [
      'Утренней звезды',
      'Восхода солнца',
      'Первого зерна',
      'Руки дождя',
      'Второго зерна',
      'Середины года',
      'Высокого солнца',
      'Последнего зерна',
      'Огня очага',
      'Начала морозов',
      'Заката солнца',
      'Вечерней звезды'
    ];

    int monthIndex = monthStrings.indexOf(monthString);
    if (monthIndex == -1) {
      throw FormatException('Invalid month string: $monthString');
    }
    return monthIndex + 1;
  }

  int _parseMonth(String month) {
    List<String> months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек'
    ];
    int monthIndex = months.indexOf(month);
    if (monthIndex == -1) {
      throw FormatException('Invalid month string: $month');
    }
    return monthIndex + 1;
  }

  String getTime({bool withSeconds = false}) {
    if (date == null) return "во сколько-то";
    return DateFormat('HH:mm${withSeconds ? ':ss' : ''}').format(date!);
  }

  String getDate() {
    if (date == null) return "когда-то";
    if (date!.year == 1970) return DateFormat('dd.MM').format(date!);
    return DateFormat('dd.MM.yy').format(date!);
  }

  /// Gets date dependent on the current date.
  String getAdaptiveDate() {
    if (date == null) return dateRaw;
    DateTime now = DateTime.now();
    DateTime nowDateOnly = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime dateOnly = DateTime(date!.year, date!.month, date!.day);
    if (dateOnly == nowDateOnly) {
      return 'Сегодня, ${getTime()}';
    } else if (dateOnly == yesterday) {
      return 'Вчера, ${getTime()}';
    } else {
      return '${getDate()} ${getTime()}';
    }
  }
}
