# Fiboss WebView App

A Flutter WebView application with a splash screen.

## Features

- **Splash Screen**: Displays "Fiboss loading" text with a loading indicator for 3 seconds
- **WebView**: Full-featured in-app browser with:
  - Pull to refresh
  - Loading progress indicator
  - Navigation controls (back, forward, home)
  - Hardware back button support
  - JavaScript enabled

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── controllers/                        # Business logic layer
│   ├── splash_controller.dart         # Splash screen logic
│   └── webview_controller.dart        # WebView logic and controls
└── screens/                           # UI layer
    ├── splash_screen.dart             # Splash screen UI
    └── webview_screen.dart            # WebView screen UI
```

## Configuration

### Change the Default URL

Edit `lib/controllers/webview_controller.dart`:

```dart
String initialUrl = 'https://www.google.com'; // Change this to your desired URL
```

### Adjust Splash Duration

Edit `lib/controllers/splash_controller.dart`:

```dart
static const Duration splashDuration = Duration(seconds: 3); // Change duration here
```

## Running the App

```bash
flutter pub get
flutter run
```

## Permissions

The app requires internet permission (already configured in AndroidManifest.xml)

## Dependencies

- `flutter_inappwebview: ^6.0.0` - For in-app WebView functionality
