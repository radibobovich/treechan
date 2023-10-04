// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';

downloadImage(String url) async {
  await GallerySaver.saveImage(url, toDcim: false);
  // var response =
  //     await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  // await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
  //     quality: 100, name: "hello");
}

downloadVideo(String url) async {
  await GallerySaver.saveVideo(url, toDcim: false);
}

// import 'dart:io';

// import 'package:image_downloader/image_downloader.dart';

// import '../../main.dart';

// class ImageDownloadService {
//   ImageDownloadService();

//   late String? url;
//   void setUrl({required String url}) {
//     this.url = url;
//   }

//   Future<void> downloadImage() async {
//     if (url == null) {
//       return;
//     }
//     try {
//       // Saved with this method.
//       String? imageId;
//       if (Platform.isAndroid) {
//         imageId = await ImageDownloader.downloadImage(url!,
//             destination: _getDestinationType());
//       } else {
//         return;
//       }

//       if (imageId == null) {
//         return;
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
// }

// AndroidDestinationType _getDestinationType() {
//   String androidDestinationType = prefs.getString('androidDestinationType')!;
//   if (androidDestinationType == 'directoryDownloads') {
//     return AndroidDestinationType.directoryDownloads;
//   } else if (androidDestinationType == 'directoryDCIM') {
//     return AndroidDestinationType.directoryDCIM;
//   } else if (androidDestinationType == 'directoryPictures') {
//     return AndroidDestinationType.directoryPictures;
//   } else {
//     return AndroidDestinationType.directoryMovies;
//   }
// }
