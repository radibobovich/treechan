import 'package:flutter/material.dart';
import 'package:treechan/utils/user_platform.dart';

class UserPlatformIcons extends StatelessWidget {
  const UserPlatformIcons({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        // padding: EdgeInsets.all(0),
        child: systemSvgIcons[getUserOS(userName)]!,
      ),
      browserSvgIcons[getUserBrowser(userName)]!
    ]);
  }
}
