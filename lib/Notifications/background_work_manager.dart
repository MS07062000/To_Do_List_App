import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
import 'package:to_do_list_app/Notifications/notes_notification.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Timer.periodic(const Duration(minutes: 1), (timer) async {
    //   var connectivityResult = await (Connectivity().checkConnectivity());
    //   bool locationServices = await locationPermissionAndServicesEnabled();
    //   if (connectivityResult == ConnectivityResult.mobile ||
    //       connectivityResult == ConnectivityResult.wifi && locationServices) {
    //     List<NoteModel> notes = await findNotesFromDestination(
    //         Position(
    //           latitude: 0,
    //           longitude: 0,
    //           speed: 0,
    //           accuracy: 0,
    //           altitude: 0,
    //           heading: 0,
    //           speedAccuracy: 0,
    //           timestamp: DateTime.now(),
    //         ),
    //         double.maxFinite,
    //         false);
    //     if (notes.isNotEmpty) {
    //       LocationNotificationHelper();
    //     } else {
    //       timer.cancel();
    //     }
    //   }
    // });
    if (task == "backgroundWorkManager") {
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool locationServices = await locationPermissionAndServicesEnabled();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi && locationServices) {
        List<NoteModel> notes = await findNotesFromDestination(
            Position(
              latitude: 0,
              longitude: 0,
              speed: 0,
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speedAccuracy: 0,
              timestamp: DateTime.now(),
            ),
            double.maxFinite,
            false);
        if (notes.isNotEmpty) {
          LocationNotificationHelper();
          Workmanager().registerPeriodicTask("1", "backgroundWorkManager",
              existingWorkPolicy: ExistingWorkPolicy.replace);
        } else {
          Workmanager().cancelByUniqueName("1");
        }
      }
    }

    return Future.value(true);
  });
}

class BackgroundWorkManager {
  void initializeWorkManager() {
    Workmanager().initialize(callbackDispatcher);
  }

  void registerTask() {
    Workmanager().registerPeriodicTask("1", "backgroundWorkManager",
        existingWorkPolicy: ExistingWorkPolicy.replace);
  }

  BackgroundWorkManager() {
    initializeWorkManager();
    registerTask();
  }
}
