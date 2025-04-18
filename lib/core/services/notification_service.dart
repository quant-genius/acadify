
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling notifications - both local and remote (FCM)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  /// Factory constructor to return the singleton instance
  factory NotificationService() => _instance;
  
  /// Private constructor for singleton pattern
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  SharedPreferences? _prefs;
  
  /// Preference key for notifications enabled setting
  static const String _prefsKey = 'notifications_enabled';
  
  /// Initialize notification services
  Future<void> init() async {
    // Initialize shared preferences
    _prefs = await SharedPreferences.getInstance();
    
    // Request permission for notifications
    await _requestPermissions();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
  }
  
  /// Request permission for notifications
  Future<void> _requestPermissions() async {
    // Request permissions for local notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // Request permissions for Firebase Cloud Messaging
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }
  
  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }
  
  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Get the token for this device
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
      
      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        
        // Show a local notification
        _showLocalNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'New notification',
          body: message.notification?.body ?? '',
          payload: message.data.toString(),
        );
      }
    });
    
    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state by notification');
        _handleNotificationTap(message.data.toString());
      }
    });
    
    // Handle background messages when the app is in the background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background state by notification');
      _handleNotificationTap(message.data.toString());
    });
  }
  
  /// Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isNotificationsEnabled()) return;
    
    await _showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }
  
  /// Internal method to show a local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  /// Handler for notification tap
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped with payload: ${response.payload}');
    _handleNotificationTap(response.payload);
  }
  
  /// Handle the notification tap - navigate to appropriate screen
  void _handleNotificationTap(String? payload) {
    // TODO: Implement navigation based on notification payload
    if (payload == null) return;
    
    // Here we would typically parse the payload and navigate to the appropriate screen
    // For example:
    // final data = jsonDecode(payload);
    // if (data['type'] == 'message') {
    //   // Navigate to message screen
    // } else if (data['type'] == 'post') {
    //   // Navigate to post screen
    // }
  }
  
  /// Subscribe to a topic for notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }
  
  /// Unsubscribe from a topic for notifications
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
  
  /// Check if notifications are enabled
  bool isNotificationsEnabled() {
    return _prefs?.getBool(_prefsKey) ?? true;
  }
  
  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_prefsKey, enabled);
  }
}
