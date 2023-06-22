import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Notifications/notification_action.dart';
import 'package:vibration/vibration.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse details) async {
  if (details.payload == 'location_zone') {
    setNotified(details.id);
    if (details.actionId!.compareTo('completed') == 0) {
      setDeleteOfAllSelectedNote([details.id]);
    }
    await FlutterLocalNotificationsPlugin().cancel(details.id ?? -1);
  }
}

class LocationNotificationHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String notificationChannelId = 'location_channel';
  String notificationChannelName = 'Location Notifications';
  String notificationChannelDescription =
      'Notifications for location-based notes';
  void initializeApp() {
    initializeNotifications();
    startLocationMonitoring();
  }

  void initializeNotifications() async {
    // flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()!
    //     .requestPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');
    InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) async {
    if (details.payload == 'location_zone') {
      setNotified(details.id);
      // print(details.actionId);
      if (details.actionId!.compareTo('completed') == 0) {
        setDeleteOfAllSelectedNote([details.id]);
      }

      await flutterLocalNotificationsPlugin.cancel(details.id ?? -1);
    }
  }

  void startLocationMonitoring() {
    print("Inside notification");
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
        timeLimit: Duration(minutes: 1));
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
      checkLocationZoneAndNotifyNotes(position);
    }, onError: (dynamic error) {
      startLocationMonitoring();
    });
  }

  void checkLocationZoneAndNotifyNotes(Position currentPosition) async {
    List<NoteModel> notes =
        await findNotesFromDestination(currentPosition, 100, true);
    for (NoteModel note in notes) {
      showNotification(note);
      setNotified(note.key);
      vibrateDevice();
    }
  }

  void showNotification(NoteModel note) async {
    List<NotificationAction> notificationActions = [
      NotificationAction('completed', 'Complete'),
    ];

    List<AndroidNotificationAction> androidActions =
        notificationActions.map((action) {
      return AndroidNotificationAction(action.id, action.title,
          titleColor: Colors.green);
    }).toList();

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            notificationChannelId, notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            groupKey: DateTime.now().millisecondsSinceEpoch.toString(),
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
