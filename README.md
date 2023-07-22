## Project Configuration

### 1. Add Google Maps API Key in `android/local.properties`

To avoid errors in the `AndroidManifest.xml` file, you need to add your Google Maps API key to the `android/local.properties` file. Follow these steps:

1. Open the `android/local.properties` file in your project.
2. Add a new line with the following content: `googleMapApiKey=yourApiKey`, replacing `yourApiKey` with your actual Google Maps API key.
3. Save the file.

### 2. Update `lib/Map/google_map_view.dart`

The `google_map_view.dart` file contains the configuration for the `PlacePicker` widget. Follow these steps to update it:

1. Open the `lib/Map/google_map_view.dart` file in your project.
2. Locate the `PlacePicker` widget.
3. Update the value of the `apiKey` parameter with your actual Google Maps API key. It should look like `PlacePicker(apiKey: 'yourApiKey')`.
4. Save the file.

Make sure to replace `yourApiKey` with your actual Google Maps API key in both configurations.

### 3. Update `ios/Runner/AppDelegate.swift`
Replace "YOUR KEY HERE" with Google Maps API key.
