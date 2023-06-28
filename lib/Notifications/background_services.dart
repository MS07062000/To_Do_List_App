import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
import 'package:to_do_list_app/Notifications/notes_notification.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    Timer.periodic(const Duration(minutes: 2), (timer) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool locationServices = await locationPermissionAndServicesEnabled();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi && locationServices) {
        log("inside background");
        // List<NoteModel> notes = await findNotesFromDestination(
        //     Position(
        //       latitude: 0,
        //       longitude: 0,
        //       speed: 0,
        //       accuracy: 0,
        //       altitude: 0,
        //       heading: 0,
        //       speedAccuracy: 0,
        //       timestamp: DateTime.now(),
        //     ),
        //     double.maxFinite,
        //     false);
        // if (notes.isNotEmpty) {
        LocationNotificationHelper();
        // } else {
        //   service.invoke('stopSelf');
        // }
      }
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

class BackgroundServices {
  final service = FlutterBackgroundService();
  void initializeBackgroundService() async {
    bool isRunnning = await service.isRunning();
    log(isRunnning.toString());
    if (!isRunnning) {
      await service.configure(
          androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            autoStart: true,
            isForegroundMode: true,
          ),
          iosConfiguration: IosConfiguration());
      service.startService();
    }
  }

  void stopService() {
    service.invoke('stopSelf');
  }

  BackgroundServices() {
    initializeBackgroundService();
  }
}
