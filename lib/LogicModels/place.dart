import 'dart:io';
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
  final String vicinity;

  Place({required this.geometry, required this.name, required this.vicinity});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      geometry: Geometry.fromJson(json['geometry']),
      name: json['formatted_address'],
      vicinity: json['vicinity'],
    );
  }
}
