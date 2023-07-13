import 'package:flutter/material.dart';

class NoConnectionPlaceholder extends StatelessWidget {
  const NoConnectionPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Icon(
            Icons.signal_wifi_off,
            size: 75,
          ),
        ),
        Text('Проверьте подключение к Интернету.')
      ],
    ));
  }
}
