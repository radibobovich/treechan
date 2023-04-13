import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treechan/services/date_time_service.dart';

void main() {
  List<String> dates = [
    '06/04/22 Срд 17:16:54',
    '13/04/23 Чтв 16:29:40',
    '14/08/19 Срд 10:37:00',
    '19/01/18 Птн 22:55:11',
    'Пнд 27 Июн 2011 11:21:54',
    '06:23:22 Лордас, 16-й день Высокого солнца',
    '08:10:29 Турдас, 13-й Руки дождя',
    '06:32:22 Морндас, 3-й Руки дождя',
    '06:42:04 Сандас, 9-й Руки дождя',
    '23:59:21 Фредас, 17-й Первого зерна',
    '22:20:11 Лордас, 2-й день Высокого солнца',
    '14:44:20 Турдас, 2-й день Огня очага'
  ];
  for (String dateRaw in dates) {
    test('date: $dateRaw', () {
      final DateTimeService dtService = DateTimeService(dateRaw: dateRaw);

      expect(dtService.date, isNotNull);
      debugPrint('Result: ${dtService.getAdaptiveDate()}');
    });
  }
}
