import 'dart:async';

class SplashController {
  // Duration for splash screen (reduced since we're preloading)
  static const Duration splashDuration = Duration(seconds: 10);

  // Navigate after delay
  Future<void> navigateAfterDelay(Function onComplete) async {
    await Future.delayed(splashDuration);
    onComplete();
  }
}
