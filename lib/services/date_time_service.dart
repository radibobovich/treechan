import 'package:intl/intl.dart';

class DateTimeService {
  DateTimeService({required this.dateRaw}) {
    _parse();
  }
  final String dateRaw;

  late DateTime date;

  void _parse() {
    // 19/03/23 Fri 13:45:30
    List<String> parts = dateRaw.split(' ');
    List<String> dateParts = parts[0].split('/');
    List<String> timeParts = parts[2].split(':');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]) + 2000;
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    date = DateTime(year, month, day, hour, minute, second);
  }

  String getTime({bool withSeconds = false}) {
    return DateFormat('HH:mm${withSeconds ? ':ss' : ''}').format(date);
  }

  String getDate() {
    return DateFormat('dd.MM.yy').format(date);
  }

  /// Gets date dependent on the current date.
  String getAdaptiveDate() {
    DateTime now = DateTime.now();
    DateTime nowDateOnly = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == nowDateOnly) {
      return 'Сегодня, ${getTime()}';
    } else if (dateOnly == yesterday) {
      return 'Вчера, ${getTime()}';
    } else {
      return '${getDate()} ${getTime()}';
    }
  }
}
