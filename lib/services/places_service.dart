import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicModels/place.dart';
import 'package:final_project_yroz/LogicModels/place_search.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';

class PlacesService {

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$secret.API_KEY';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$secret.API_KEY';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(double lat, double lng, String placeType) async {
    Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
    placeType = placeType.toLowerCase();
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?location=$lat,$lng&type=$placeType&rankby=distance&key=$secret.API_KEY';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }

  Future<List<Place>> getPlacesFromList(String placeType) async {
    List<StoreDTO> physicalStores = await StoreStorageProxy().fetchAllPhysicalStores();
    List<OnlineStoreDTO> onlineStores = await StoreStorageProxy().fetchAllOnlineStores();
    if(placeType!=""){
      physicalStores = physicalStores.where((element) => element.categories.contains(placeType)).toList();
      onlineStores = onlineStores.where((element) => element.categories.contains(placeType)).toList();
    }
    Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
    var googleGeocoding = GoogleGeocoding(secret.API_KEY);
    List<Place> places = [];
    for(StoreDTO store in physicalStores){
      GeocodingResponse? address = await googleGeocoding.geocoding.get(store.address, []);
      if(address!=null)
        places.add(Place.fromStore(store.name, address, store.address));
    }
    for(OnlineStoreDTO store in onlineStores){
      GeocodingResponse? address = await googleGeocoding.geocoding.get(store.address, []);
      if(address!=null)
        places.add(Place.fromStore(store.name, address, store.address));
    }
    return places;
  }
}
