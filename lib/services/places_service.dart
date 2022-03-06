import 'package:final_project_yroz/DTOs/PhysicalStoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicModels/place.dart';
import 'package:final_project_yroz/LogicModels/place_search.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  final key = 'AIzaSyAfdPcHbriyq8QOw4hoCMz8sFp3dt8oqHg';

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(double lat, double lng, String placeType) async {
    placeType = placeType.toLowerCase();
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?location=$lat,$lng&type=$placeType&rankby=distance&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }

  Future<List<Place>> getPlacesFromList(String placeType) async {
    List<PhysicalStoreDTO> stores = await StoreStorageProxy().fetchAllPhysicalStores();
    if(placeType!=""){
      stores = stores.where((element) => element.categories.contains(placeType)).toList();
    }
    var googleGeocoding = GoogleGeocoding("AIzaSyAfdPcHbriyq8QOw4hoCMz8sFp3dt8oqHg");
    List<Place> places = [];
    for(PhysicalStoreDTO store in stores){
      GeocodingResponse? address = await googleGeocoding.geocoding.get(store.address, []);
      if(address!=null)
        places.add(Place.fromStore(store.name, address, store.address));
    }
    return places;
  }
}
