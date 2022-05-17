import 'dart:io';

import 'package:final_project_yroz/LogicModels/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter/material.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import 'geolocator_service.dart';

class MarkerService {
  LatLngBounds? bounds(Set<Marker>? markers) {
    if (markers == null || markers.isEmpty) return null;
    return createBounds(markers.map((m) => m.position).toList());
  }

  LatLngBounds createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  Marker createMarkerFromPlace(Place place, bool center) {
    var markerId = place.name;
    if (center) markerId = 'center';

    return Marker(
        markerId: MarkerId(markerId),
        draggable: false,
        visible: (center) ? false : true,
        infoWindow: InfoWindow(title: place.name, snippet: place.vicinity),
        position:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        onTap: () async {
          String dest_lat = place.geometry.location.lat.toString();
          String dest_lng = place.geometry.location.lng.toString();
          String origin_lat = (await GeolocatorService().getCurrentLocation())
              .latitude
              .toString();
          String origin_lng = (await GeolocatorService().getCurrentLocation())
              .longitude
              .toString();
          Secret secret =
              await SecretLoader(secretPath: "assets/secrets.json").load();
          if (!Platform.isIOS) {
            MapsLauncher.launchCoordinates(
                double.parse(dest_lat), double.parse(dest_lng));
          } else {
            MapsLauncher.launchQuery(place.address);
          }
          // String googleUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin_lat,$origin_lng&destination=$dest_lat,$dest_lng&key=${secret.API_KEY}';
          // if (await canLaunch(googleUrl)) {
          //   await launch(googleUrl);
          // } else {
          //   throw 'Could not open the map.';
          // }
        });
  }
}
