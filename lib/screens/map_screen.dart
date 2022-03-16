import 'dart:async';

import 'package:final_project_yroz/LogicModels/place.dart';
import 'package:final_project_yroz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/application_bloc.dart';
import 'package:provider/provider.dart';

import '../dummy_data.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation initialLocation;
  final bool isSelecting;

  MapScreen({
    this.initialLocation =
        const PlaceLocation(latitude: 31.262218, longitude: 34.801461),
    this.isSelecting = false,
  }) {}

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription locationSubscription;
  late StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);

    //Listen for selected Location
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _locationController.text = place.name;
        _goToPlace(place);
      } else
        _locationController.text = "";
    });

    applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 50));
    });

    applicationBloc.createMarkers();
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    _locationController.dispose();
    locationSubscription.cancel();
    boundsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
        body: applicationBloc.currentLocation == null
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _locationController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) =>
                            applicationBloc.searchPlaces(value),
                        onTap: () => applicationBloc.clearSelectedLocation(),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height - 200,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  applicationBloc.currentLocation!.latitude,
                                  applicationBloc.currentLocation!.longitude),
                              zoom: 14,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _mapController.complete(controller);
                            },
                            markers: Set<Marker>.of(applicationBloc.markers),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            children: [
                              ...DUMMY_CATEGORIES.map(
                                (e) => FilterChip(
                                  label: Text(e.title),
                                  onSelected: (val) => applicationBloc
                                      .togglePlaceType(e.title, val),
                                  selected:
                                      applicationBloc.placeType == e.title,
                                  selectedColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (applicationBloc.searchResults != null &&
                            applicationBloc.searchResults!.length != 0)
                          Container(
                              height: 300.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.6),
                                  backgroundBlendMode: BlendMode.darken)),
                        if (applicationBloc.searchResults != null)
                          Container(
                            height: 300.0,
                            child: ListView.builder(
                                itemCount:
                                    applicationBloc.searchResults!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      applicationBloc
                                          .searchResults![index].description,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onTap: () {
                                      applicationBloc.setSelectedLocation(
                                          applicationBloc
                                              .searchResults![index].placeId);
                                    },
                                  );
                                }),
                          ),
                      ],
                    ),
                  ],
                ),
              ));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
  }
}
