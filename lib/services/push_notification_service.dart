import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level function to handle background messages
/// This MUST be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
    print('Background message data: ${message.data}');
    print('Background notification: ${message.notification?.title}');
  }
}

/// Service class to handle Firebase Cloud Messaging (FCM) push notifications
class PushNotificationService {
  // Private constructor to prevent instantiation
  PushNotificationService._();
  
  // Singleton instance
  static final PushNotificationService _instance = PushNotificationService._();
  static PushNotificationService get instance => _instance;
  
  // Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Local Notifications Plugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Stream controller for notification tap events
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  
  /// Stream to listen to notification tap events
  Stream<RemoteMessage> get onMessageTapped => _messageStreamController.stream;
  
  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request notification permissions
      await requestNotificationPermission();
      
      // Get and print FCM token
      final token = await getDeviceToken();
      if (kDebugMode) {
        print('📱 FCM Device Token: $token');
      }
      
      // Setup message handlers
      await _setupMessageHandlers();
      
      // Handle notification tap when app is opened from terminated state
      await setupInteractedMessage();
      
      if (kDebugMode) {
        print('✅ Push Notification Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Push Notification Service: $e');
      }
    }
  }
  
  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Linux initialization settings
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    
    // Combined initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    
    // Initialize the plugin with notification tap handler
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          if (kDebugMode) {
            print('Notification tapped with payload: ${response.payload}');
          }
        }
      },
    );
    
    // Create Android notification channel
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }
  
  /// Create Android notification channel
  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // Channel ID
      'Default Notifications', // Channel name
      description: 'This channel is used for important notifications.', // Channel description
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      enableVibration: true,
    );
    
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Request notification permission from user
  Future<bool> requestNotificationPermission() async {
    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        final NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        
        if (kDebugMode) {
          print('iOS Notification Permission status: ${settings.authorizationStatus}');
        }
        
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
               settings.authorizationStatus == AuthorizationStatus.provisional;
      }
      
      // For Android 13+ (API level 33+), request notification permission
      if (Platform.isAndroid) {
        final NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        
        if (kDebugMode) {
          print('Android Notification Permission status: ${settings.authorizationStatus}');
        }
        
        return settings.authorizationStatus == AuthorizationStatus.authorized;
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
      return false;
    }
  }
  
  /// Get FCM device token
  Future<String?> getDeviceToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      
      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('🔄 FCM Token refreshed: $newToken');
        }
        // TODO: Send the new token to your backend server
      });
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device token: $e');
      }
      return null;
    }
  }
  
  /// Setup message handlers for different app states
  Future<void> _setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('📬 Foreground message received:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
      }
      
      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });
    
    // Handle when user taps on notification while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('📲 Notification tapped (app in background):');
        print('Title: ${message.notification?.title}');
        print('Data: ${message.data}');
      }
      
      // Add message to stream for app to handle
      _messageStreamController.add(message);
      
      // TODO: Navigate to specific screen based on message data
      // Example: Navigator.pushNamed(context, '/notification-detail', arguments: message.data);
    });
  }
  
  /// Setup handler for when app is opened from terminated state via notification tap
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the app to open from a terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      if (kDebugMode) {
        print('📱 App opened from terminated state via notification:');
        print('Title: ${initialMessage.notification?.title}');
        print('Data: ${initialMessage.data}');
      }
      
      // Add message to stream for app to handle
      _messageStreamController.add(initialMessage);
      
      // TODO: Navigate to specific screen based on message data
      // Example: Navigator.pushNamed(context, '/notification-detail', arguments: initialMessage.data);
    }
  }
  
  /// Show local notification (used for foreground messages)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Extract notification data
      final notification = message.notification;
      
      if (notification == null) {
        if (kDebugMode) {
          print('⚠️ Message has no notification payload');
        }
        return;
      }
      
      // Android notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'default_channel', // Must match the channel ID created earlier
        'Default Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );
      
      // iOS notification details
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Combined notification details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode, // Notification ID
        notification.title ?? 'New Notification',
        notification.body ?? '',
        platformChannelSpecifics,
        payload: message.data.toString(), // Pass data as payload
      );
      
      if (kDebugMode) {
        print('✅ Local notification displayed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing local notification: $e');
      }
    }
  }
  
  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topic $topic: $e');
      }
    }
  }
  
  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topic $topic: $e');
      }
    }
  }
  
  /// Dispose resources
  void dispose() {
    _messageStreamController.close();
  }
}
