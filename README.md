Important configuration need to be done when you pull this repo:
Add googleMapApiKey in android/localproperties file as googleMapApiKey=yourApiKey so that AndroidManifest.xml don't throw error.
In lib/Map/google_map_view.dart file PlacePicker has parameter apiKey place yourApiKey.
