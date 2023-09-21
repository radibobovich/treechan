import 'package:treechan/di/injection.dart';

const String debugThreadPath = 'assets/dev/thread.json';
const List<String> debugThreadUpdatePaths = [
  'assets/dev/new_posts1.json',
  'assets/dev/new_posts2.json',
  'assets/dev/new_posts3.json',
  'assets/dev/new_posts4.json',
];
const String debugBoardTag = 'b';
const int debugThreadId = 293335313;

/// Environment variable.
///
/// Set it to [Env.dev] to use [MockThreadLoader] and [MockThreadRefresher].
///
/// Don't forget to set it back to [Env.prod] before release build, otherwise
/// an exception will be thrown.
const env = Env.dev;
