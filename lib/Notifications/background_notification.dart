import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
import 'package:to_do_list_app/Notifications/notes_notification.dart';
import 'package:workmanager/workmanager.dart';

const String simpleTaskKey = "backgroundNotification";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == simpleTaskKey) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool locationServices = await locationPermissionAndServicesEnabled();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi && locationServices) {
        LocationNotificationHelper();
      }
    }

    Workmanager().registerOneOffTask(
      "1",
      simpleTaskKey,
      initialDelay: const Duration(minutes: 1),
    );

    return Future.value(true);
  });
}

class BackgroundNotification {
  void initializeWorkManager() {
    Workmanager().initialize(callbackDispatcher);
  }

  void registerTask() {
    Workmanager().registerOneOffTask(
      "1",
      simpleTaskKey,
      initialDelay: const Duration(minutes: 1),
    );
  }

  BackgroundNotification() {
    initializeWorkManager();
    registerTask();
  }
}
