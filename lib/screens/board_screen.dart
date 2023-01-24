import 'package:flutter/material.dart';
import '../services/board_service.dart';
import '../board_json.dart';
import 'package:flutter_html/flutter_html.dart';
import 'thread_screen.dart';
import '/screens/thread_screen.dart';

// screen where you can scroll threads of the board
class BoardScreen extends StatefulWidget {
  const BoardScreen(
      {super.key, required this.boardName, required this.boardTag});
  final String boardName;
  final String boardTag;
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late Future<List<Thread>?> threadList;
  @override
  void initState() {
    super.initState();
    threadList = getThreadsByBump(widget.boardTag);
  }

// List of threads
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Thread>?>(
              future: threadList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return ThreadCard(thread: snapshot.data?[index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                return const CircularProgressIndicator();
              })),
    );
  }
}

// Represents thread in list of threads
class ThreadCard extends StatelessWidget {
  final Thread? thread;
  const ThreadCard({
    Key? key,
    required this.thread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 16),
                  child: CardHeader(thread: thread),
                ),
                Text.rich(TextSpan(
                  text: thread?.subject ?? "No subject",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
          ImagesGroup(thread: thread),
          Html(data: thread?.comment, style: {
            '#': Style(
              maxLines: 15,
              textOverflow: TextOverflow.ellipsis,
            )
          }),
          CardFooter(thread: thread)
        ],
      ),
    );
  }

  // Column cardFooter(BuildContext context) {
  //   return Column(
  //     children: [
  //       const Divider(
  //         thickness: 1,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
  //         child: Row(
  //           children: [
  //             const Icon(Icons.question_answer, size: 20),
  //             Text.rich(
  //                 // post count
  //                 TextSpan(text: thread?.postsCount.toString() ?? "count"),
  //                 style: const TextStyle(fontSize: 14)),
  //             const Spacer(),
  //             InkWell(
  //                 // button go to thread
  //                 child: const Text(
  //                   "В тред",
  //                 ),
  //                 onTap: () {
  //                   Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) => ThreadScreen(
  //                               threadId: thread?.op ?? 0,
  //                               tag: thread?.board ?? "b")));
  //                 }),
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  // }
}

class ImagesGroup extends StatelessWidget {
  const ImagesGroup({
    Key? key,
    required this.thread,
  }) : super(key: key);

  final Thread? thread;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _getImages(thread?.files),
        ),
      ),
    );
  }
}

List<Widget> _getImages(List<File>? files) {
  if (files == null) {
    // return empty image list
    return List<Widget>.filled(1, const SizedBox.shrink());
  }
  List<Widget> images = List<Widget>.filled(8, const SizedBox.shrink());
  for (int i = 0; i < files.length; i++) {
    if (files[i].thumbnail != null) {
      images[i] =
          Image.network(files[i].thumbnail!, height: 140, fit: BoxFit.contain);
    }
  }
  return images;
}

// contains username and date
class CardHeader extends StatelessWidget {
  const CardHeader({
    Key? key,
    required this.thread,
  }) : super(key: key);

  final Thread? thread;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(TextSpan(
            text: thread?.name ?? "No author", //username
            style: const TextStyle(fontSize: 14))),
        const Spacer(),
        Text.rich(TextSpan(
            text: thread?.date ?? "a long time ago", //date
            style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

class CardFooter extends StatelessWidget {
  const CardFooter({
    Key? key,
    required this.thread,
  }) : super(key: key);

  final Thread? thread;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          child: Row(
            children: [
              const Icon(Icons.question_answer, size: 20),
              Text.rich(
                  // post count
                  TextSpan(text: thread?.postsCount.toString() ?? "count"),
                  style: const TextStyle(fontSize: 14)),
              const Spacer(),
              InkWell(
                  // button go to thread
                  child: const Text(
                    "В тред",
                  ),
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => ThreadScreen(
                    //             threadId: thread?.op ?? 0,
                    //             tag: thread?.board ?? "b")));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ThreadScreen(
                                threadId: thread!.num_ ?? 0,
                                tag: thread!.board ?? "b")));
                  }),
            ],
          ),
        )
      ],
    );
  }
}
