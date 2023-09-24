// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treechan/presentation/widgets/shared/user_platform_icons.dart';

void main() {
  // Widget test of UserPlatformIcons.
  // we push the widget to the screen and check if it's rendered correctly.
  final List<String> userNames = [
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Firefox based)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Chromium based)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Mobile Safari)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Safari)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Opera)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Яндекс браузер)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Palemoon)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: Internet Explorer)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 10: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows Vista: Firefox based)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 7: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Microsoft Windows 8: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Apple Mac: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Apple GayPhone: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(iOS: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Fuchsia: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(Haiku: unknown)</span>',
    'Аноним&nbsp;<span style=\"color:rgb(164,164,164);\">(unknown: unknown)</span>',
  ];

  /// The purpose of this test is to check if any exception is thrown by
  /// flutter_svg when it tries to parse the svg icons.
  testWidgets('UserPlatformIcons', (WidgetTester tester) async {
    for (final userName in userNames) {
      await tester
          .pumpWidget(MaterialApp(home: UserPlatformIcons(userName: userName)));
      expect(find.byType(Row), findsOneWidget);
    }
  });
}
