class LinkService {
  LinkService();

  late String url;
  late Uri parsedUrl;
  void getLink(String url) {
    this.url = url;
    parsedUrl = Uri.parse(url);
  }
}
