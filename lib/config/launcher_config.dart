import 'package:url_launcher/url_launcher.dart';

class LauncherConfig {
  LauncherConfig({required this.uri});

  String uri;

  void launchURL() async {
    if (!await launchUrl(Uri.parse(uri),
        mode: LaunchMode.externalApplication)) {
      throw "Error";
    }
  }
}
