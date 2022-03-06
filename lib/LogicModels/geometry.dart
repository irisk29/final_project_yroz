import 'package:final_project_yroz/LogicModels/location.dart';

import 'package:google_geocoding/google_geocoding.dart' as geo;

class Geometry {
  final Location location;

  Geometry({required this.location});

  Geometry.fromJson(Map<dynamic, dynamic> parsedJson)
      : location = Location.fromJson(parsedJson['location']);

  Geometry.fromLocation(geo.Location location)
      : location = Location.fromLocation(location);
}
