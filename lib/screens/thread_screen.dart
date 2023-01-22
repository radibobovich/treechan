import 'package:flutter/material.dart';
import 'package:treechan/services/thread_service.dart';
import 'board_screen.dart';
import '../board_json.dart';

// class ThreadScreen extends StatefulWidget {
//   const ThreadScreen({super.key, required this.tag, required this.threadId});
//   final int threadId;
//   final String tag;
//   @override
//   State<ThreadScreen> createState() => _ThreadScreenState();
// }

// class _ThreadScreenState extends State<ThreadScreen> {
//   //late Thread? thread;
//   late Future<List<Widget>?> thread;
//   @override
//   void initState() {
//     super.initState();
//     //_getThread().then((value) => {thread = value});
//   }

//   Future<Thread?> _getThread() async {
//     return getThread(widget.tag, widget.threadId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Тред"),
//         ),
//         body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             // child: ListView.builder(itemBuilder: (context, index) {
//             //   return Card(child: Text(thread?.posts?[index].comment ?? ""));
//             // }))
//             child: FutureBuilder<List<Widget>?>(
//                 future: thread,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ListView.builder(
//                         itemCount: snapshot.data?.length,
//                         itemBuilder: (context, index) {
//                           return Container();
//                         });
//                   } else if (snapshot.hasError) {
//                     return Text('${snapshot.error}');
//                   }
//                 })
//                 ));
//   }
// }

