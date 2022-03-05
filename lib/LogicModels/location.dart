import 'package:google_geocoding/google_geocoding.dart' as geo;

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Location(lat: parsedJson['lat'], lng: parsedJson['lng']);
  }

  factory Location.fromLocation(geo.Location location) {
    return Location(lat: location.lat!, lng: location.lng!);
  }
}
