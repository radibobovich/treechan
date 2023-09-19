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
