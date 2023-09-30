import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treechan/data/local/hidden_posts.database.dart';

class HiddenPostsScreen extends StatefulWidget {
  final String tag;
  final int threadId;
  const HiddenPostsScreen({
    super.key,
    required this.tag,
    required this.threadId,
  });

  @override
  State<HiddenPostsScreen> createState() => _HiddenPostsScreenState();
}

class _HiddenPostsScreenState extends State<HiddenPostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Скрытые посты - /${widget.tag}/${widget.threadId}'),
        actions: [
          IconButton(
              onPressed: () {
                HiddenPostsDatabase()
                    .removeThreadTable(widget.tag, widget.threadId);
                setState(() {});
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<List<HiddenPost>>(
        future:
            HiddenPostsDatabase().getHiddenPosts(widget.tag, widget.threadId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final HiddenPost post = snapshot.data![index];
                return Dismissible(
                    key: ValueKey(post),
                    onDismissed: (direction) {
                      HiddenPostsDatabase()
                          .removePost(widget.tag, widget.threadId, post.id);
                    },
                    child: PostTile(
                      post: post,
                      tag: widget.tag,
                    ));
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    required this.tag,
  });

  final HiddenPost post;
  final String tag;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          post.comment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(post.id.toString()),
        trailing: Text(DateFormat('HH:mm dd.MM.yy ')
            .format(DateTime.fromMillisecondsSinceEpoch(post.timestamp))),
        onTap: () {});
  }
}
