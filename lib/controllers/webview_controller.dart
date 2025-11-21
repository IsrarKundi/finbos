import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewController {
  InAppWebViewController? webViewController;
  String initialUrl = 'https://finbos.app'; // Change this to your desired URL
  
  // Progress value for loading indicator
  double progress = 0;

  void setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
  }

  void updateProgress(double newProgress) {
    progress = newProgress / 100;
  }

  Future<void> reload() async {
    await webViewController?.reload();
  }

  Future<void> goBack() async {
    if (await canGoBack()) {
      await webViewController?.goBack();
    }
  }

  Future<void> goForward() async {
    if (await canGoForward()) {
      await webViewController?.goForward();
    }
  }

  Future<bool> canGoBack() async {
    return await webViewController?.canGoBack() ?? false;
  }

  Future<bool> canGoForward() async {
    return await webViewController?.canGoForward() ?? false;
  }

  void dispose() {
    webViewController = null;
  }
}
