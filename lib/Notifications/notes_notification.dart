import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:vibration/vibration.dart';

class LocationNotificationHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String notificationChannelId = 'location_channel';
  String notificationChannelName = 'Location Notifications';
  String notificationChannelDescription =
      'Notifications for location-based reminders';

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestBadgePermission: false,
      requestSoundPermission: false,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {}

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void initializeApp() {
    initializeNotifications();
    startLocationMonitoring();
  }

  void startLocationMonitoring() {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
        timeLimit: Duration(minutes: 1));
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) => checkLocationZoneAndNotifyNotes(position));
  }

  void checkLocationZoneAndNotifyNotes(Position currentPosition) async {
    List<NoteModel> notes = await getUnreadNotes();
    for (NoteModel note in notes) {
      double targetLatitude = double.parse(note.destination.split(',')[0]);
      double targetLongitude = double.parse(note.destination.split(',')[1]);

      // Calculate the distance between current and target location
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        targetLatitude,
        targetLongitude,
      );

      // Define the radius of the location zone in meters
      double locationZoneRadius = 100;

      // Check if the user is within the location zone
      if (distanceInMeters <= locationZoneRadius) {
        // User is within the location zone
        showNotification(note);
        vibrateDevice();
      }
    }
  }

  void showNotification(NoteModel note) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            notificationChannelId, notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true);

    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: true,
    ); // check out properties more needed to be added

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      note.notetitle,
      notificationBody(note),
      platformChannelSpecifics,
      payload: 'location_zone',
    );
  }

  String? notificationBody(NoteModel note) {
    if (note.textnote != null) {
      return note.textnote;
    }

    if (note.checklist!.isNotEmpty) {
      return note.checklist!.join("\n");
    }
    return null;
  }

  void vibrateDevice() async {
    if (await Vibration.hasVibrator() != null) {
      Vibration.vibrate(duration: 1000);
    } else {
      if (await Vibration.hasCustomVibrationsSupport() != null) {
        Vibration.vibrate(duration: 1000);
      }
    }
  }
}
