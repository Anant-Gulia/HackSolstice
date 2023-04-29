import 'dart:async';
import 'dart:convert';
import 'package:brew_crew/Api_keys/googleMapApiKey.dart';
import 'package:brew_crew/screens/staticMap.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  /***********Controller******************/
  
  TextEditingController _startingPoint = TextEditingController();
  TextEditingController _endingPoint = TextEditingController();

  /****************************************/

  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];

  //
  // late GoogleMapController mapController;
  //
  // final LatLng _center = const LatLng(45.521563, -122.677433);
  //
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  /****************** Google Map Integeration *************/
  List<Marker> _marker = [];
  List<Marker> _list = const [
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(28.504790, 77.050090),
        infoWindow: InfoWindow(
            title: 'My Current Location'
        )

    ),

  ];


  Completer<GoogleMapController> _mapController = Completer();


  static final CameraPosition _kGooglePlex = const CameraPosition(
      target: LatLng(28.504790, 77.050090),
      zoom: 18.0
  );

  /********************************************************/


  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _marker.addAll(_list);
    _startingPoint.addListener(() {
      onChange();
    });
  }

  void onChange(){
      if( _sessionToken == null){
        setState(() {
          _sessionToken = uuid.v4();
        });
      }
      getSuggestion(_startingPoint.text);


  }

  void getSuggestion(String input) async{
    String kPLACES_API_KEY = myGoogleApikey;
    String baseURL ='https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    // print(response);
    if(response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString()) ['predictions'];
      });

    }
    else{
      throw Exception('Failed to load data');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text("Brew Crew"),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text("logout")),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
          child: Form(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0,),
              TextFormField(
                controller: _startingPoint,
                  onChanged: (val) {

                  },
                  decoration: InputDecoration(
                      labelText: "Search places with name",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          )
                      )
                  )
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: _placesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            List<Location> locations = await locationFromAddress(_placesList[index]['description']);
                            print("Latitudefesgegv");

                            print(locations.last.longitude);
                            print(locations.last.latitude);
                          },
                          title: Text(_placesList[index]['description']),
                        );
                      }
                  )
              ),

              SizedBox(height: 20.0,),
              TextFormField(
                controller: _endingPoint,
                  onChanged: (val) {

                  },
                  decoration: InputDecoration(
                      labelText: "Destination",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          )
                      )
                  )

              ),
              SizedBox(height: 20.0,),
              Expanded(child: GoogleMap(
                initialCameraPosition: _kGooglePlex,
                markers: Set<Marker>.of(_marker),
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
              ))
            ],
          ),
          ),
      ),
    );
  }
}
