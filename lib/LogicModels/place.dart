import 'dart:io';
import 'package:f_logs/f_logs.dart';
import 'package:google_geocoding/google_geocoding.dart' as geo;

import 'geometry.dart';

class PlaceLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class Place2 {
  final String id;
  final String title;
  final PlaceLocation location;
  final File image;

  Place2({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
  });
}

class Place {
  final Geometry geometry;
  final String name;
  final String? vicinity;
  final String address;

  Place({required this.geometry, required this.name, this.vicinity, required this.address});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      geometry: Geometry.fromJson(json['geometry']),
      name: json['formatted_address'],
      vicinity: json['vicinity'],
      address: json['formatted_address'],
    );
  }

  factory Place.fromStore(String name, geo.GeocodingResponse address, String add) {
    return Place(
      geometry: Geometry.fromLocation(address.results!.first.geometry!.location!),
      name: name,
      vicinity: add,
      address: address.results!.first.formattedAddress!
    );
  }
}
