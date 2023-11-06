
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';


class LocationSearchWidget extends StatefulWidget {
  @override
  _LocationSearchWidgetState createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  
  final MapController mapController = MapController();
  List<Marker> _markers = [];
 
  
  get builder => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Search'),
      ),
      body: Column(
        children: [
          Padding(
      padding: EdgeInsets.all(16.0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search',
            border: OutlineInputBorder(),
          ),
        ),

        suggestionsCallback: (pattern) async {
          
       
          String url = 'https://nominatim.openstreetmap.org/search?q={$pattern}&format=json&limit=5';
          

          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
          
            List<dynamic> suggestions = json.decode(response.body);
            return suggestions.map((suggestion) => suggestion['display_name']).toList();
          } else {
            return [];
          }
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          _searchController.text = suggestion;
          searchLocation(suggestion);
        },
      ),
    ),
  

    Expanded(
        child: FlutterMap(
        mapController: mapController,
        options:  MapOptions(
        initialCenter:
       LatLng(9.0358287, 38.7524127),
      initialZoom: 9.2,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.app',
      ),
       MarkerLayer(
        markers: _markers,
      ),
    ],
  ),
)
,
          
   ],
      ),
    );
  }




//to handle destination location

void searchLocation(String suggestion) async {
   
    

    if (suggestion.isNotEmpty) {
     
       String url   =  'https://nominatim.openstreetmap.org/search?q={$suggestion}&format=json&limit=1';


      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);
         

          setState(() {
            _markers = [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(lat, lon),
                child:  Container(
                  child: Icon(Icons.location_on,
                  color: Colors.red,)),  ), 
             
            ];
          });
        }
      }
    }
  }


}