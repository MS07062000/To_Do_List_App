import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityCheck {
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  void startStreamSubscription(context) {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      checkConnectivity(context);
    });
  }

  void stopStreamSubscription() {
    connectivitySubscription?.cancel();
  }

  void checkConnectivity(dialogcontext) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      showDialog(
        context: dialogcontext,
        barrierDismissible: false, // Dialog cannot be dismissed
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please enable your internet connection.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                checkConnectivity(
                    context); // Re-check connectivity after dismissing dialog
              },
            ),
          ],
        ),
      );
    }
  }
}
