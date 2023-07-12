import 'package:intl/intl.dart';

class DateTimeService {
  DateTimeService({required this.timestamp}) {
    _parse();
  }
  final int timestamp;

  late DateTime? date;

  void _parse() {
    try {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } catch (e) {
      date = null;
    }
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
    if (date == null) return '';
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
