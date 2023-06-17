import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Notifications/notification_action.dart';
import 'package:vibration/vibration.dart';

class LocationNotificationHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String notificationChannelId = 'location_channel';
  String notificationChannelName = 'Location Notifications';
  String notificationChannelDescription =
      'Notifications for location-based reminders';
  void initializeApp() {
    initializeNotifications();
    startLocationMonitoring();
  }

  void initializeNotifications() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  @pragma('vm:entry-point')
  void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) async {
    if (details.payload == 'location_zone') {
      // Open your app and move to the second tab
      if (details.actionId!.compareTo('completed') == 0) {
        setNotified(details.id);
        await flutterLocalNotificationsPlugin.cancel(details.id ?? -1);
      }
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) async {
    if (details.payload == 'location_zone') {
      if (details.actionId!.compareTo('completed') == 0) {
        setNotified(details.id);
        await flutterLocalNotificationsPlugin.cancel(details.id ?? -1);
      }
      // Provider.of<BottomNavBarProvider>(context, listen: false)
      //     .setCurrentIndex(1);
    }
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
    List<NoteModel> notes =
        await findNotesFromDestination(currentPosition, 1000);
    for (var note in notes) {
      showNotification(note);
      vibrateDevice();
    }
  }

  void showNotification(NoteModel note) async {
    List<NotificationAction> notificationActions = [
      NotificationAction('completed', 'Complete'),
    ];

    List<AndroidNotificationAction> androidActions =
        notificationActions.map((action) {
      return AndroidNotificationAction(
        action.id,
        action.title,
      );
    }).toList();

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            notificationChannelId, notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            actions: androidActions);

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      note.key,
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
