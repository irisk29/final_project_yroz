import 'dart:async';

import 'package:final_project_yroz/LogicModels/geometry.dart';
import 'package:final_project_yroz/LogicModels/location.dart';
import 'package:final_project_yroz/LogicModels/place.dart';
import 'package:final_project_yroz/LogicModels/place_search.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/geolocator_service.dart';
import '../services/marker_service.dart';
import '../services/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();
  final markerService = MarkerService();

  //Variables
  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  StreamController<Place?> selectedLocation =
      StreamController<Place?>.broadcast();
  StreamController<LatLngBounds?> bounds =
      StreamController<LatLngBounds?>.broadcast();
  Place? selectedLocationStatic;
  String? placeType;
  List<Marker> markers = <Marker>[];

  ApplicationBloc() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    currentLocation = await geoLocatorService.getCurrentLocation();
    selectedLocationStatic = Place(
        name: "null",
        geometry: Geometry(
          location: Location(
              lat: currentLocation!.latitude, lng: currentLocation!.longitude),
        ),
        address: "");
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    var sLocation = await placesService.getPlace(placeId);
    selectedLocation.add(sLocation);
    selectedLocationStatic = sLocation;
    searchResults = <PlaceSearch>[];
    notifyListeners();
  }

  clearSelectedLocation() {
    selectedLocation.add(null);
    selectedLocationStatic = null;
    searchResults = null;
    placeType = null;
    notifyListeners();
  }

  togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = "";
    }

    if (placeType != null) {
      var places = await placesService.getPlacesFromList(placeType!);
      markers = [];
      if (places.length > 0) {
        for (Place p in places) {
          var newMarker = markerService.createMarkerFromPlace(p, false);
          markers.add(newMarker);
        }
      }

      var locationMarker =
          markerService.createMarkerFromPlace(selectedLocationStatic!, true);
      markers.add(locationMarker);

      var _bounds = markerService.bounds(Set<Marker>.of(markers));
      bounds.add(_bounds);

      notifyListeners();
    }
  }

  createMarkers() async {
    var places = await placesService.getPlacesFromList("");
    markers = [];
    if (places.length > 0) {
      for (Place p in places) {
        var newMarker = markerService.createMarkerFromPlace(p, false);
        markers.add(newMarker);
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    bounds.close();
    super.dispose();
  }
}
