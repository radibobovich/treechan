import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/deprecated/dummy_bloc.dart';

class DummyScreen extends StatefulWidget {
  const DummyScreen({super.key});

  @override
  State<DummyScreen> createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint('build dummy');
    return Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<DummyBloc, DummyState>(
          builder: (context, state) {
            if (state is DummyLoadedState) {
              return Column(children: [
                DummyText(text: state.text),
                DummyText(text: state.text)
              ]);
            } else {
              return const CircularProgressIndicator();
            }
          },
        )
        // body: Column(
        //   children: [
        //     DummyText(text: 'dummy'),
        //     DummyText(text: 'dummy'),
        //   ],
        // )
        );
  }
}

class DummyText extends StatelessWidget {
  final String text;
  const DummyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // debugPrint('build text');
    return Text(text);
  }
}
