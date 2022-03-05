import 'package:final_project_yroz/LogicModels/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
          String dest_lat = place.geometry.location.lat as String;
          String dest_lng = place.geometry.location.lng as String;
          String origin_lat = (await GeolocatorService().getCurrentLocation()).latitude as String;
          String origin_lng = (await GeolocatorService().getCurrentLocation()).longitude as String;
          String googleUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin_lat,$origin_lng&destination=$dest_lat,$dest_lng&key=AIzaSyAfdPcHbriyq8QOw4hoCMz8sFp3dt8oqHg';
          if (await canLaunch(googleUrl)) {
            await launch(googleUrl);
          } else {
            throw 'Could not open the map.';
          }
        }
    );
  }
}
