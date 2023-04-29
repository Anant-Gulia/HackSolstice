import 'dart:async';
import 'dart:convert';
import 'package:brew_crew/Api_keys/googleMapApiKey.dart';
import 'package:brew_crew/screens/check_balance.dart';
import 'package:brew_crew/screens/create_wallet.dart';
import 'package:brew_crew/screens/get_credentials.dart';
import 'package:brew_crew/screens/mapScreen.dart';
import 'package:brew_crew/screens/prevPayments.dart';
import 'package:brew_crew/screens/staticMap.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../api_calls/api_end.dart';
import '../componenetsReusable/drawer.dart';

class Home2 extends StatefulWidget {
  Home2({Key? key}) : super(key: key);

  @override
  State<Home2> createState() => _HomeState();
}

class _HomeState extends State<Home2> {

  String email = "";
  String name = "";
  baseClient _bc = baseClient();
  /***********Controller******************/

  TextEditingController _startingPoint = TextEditingController();
  TextEditingController _endingPoint = TextEditingController();

  DetailsResult? startPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode endFocusNode;

  /****************************************/


  /****************** Google Map Integeration *************/

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

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
    email = FirebaseAuth.instance.currentUser!.email!;
    googlePlace = GooglePlace(myGoogleApikey);
    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
    _marker.addAll(_list);
    setName();

  }

  @override
  void dispose() {
    super.dispose();
    startFocusNode.dispose();
    endFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {

    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void setName() async{
    var res = await _bc.getDet("nameMob", email);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    if(take["name"] == "no_account"){
     setState(() {
       name = "Please create your wallet";
     });
    }
    else {
      setState(() {
        name = take["name"].toString() + "\'s wallet";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Taxi DC" , style: TextStyle(fontWeight: FontWeight.w400) ),
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text("Logout")),
        ],
      ),
      drawer: CustomDrawer(isDriver: false,),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0,),
              TextFormField(
                  focusNode: startFocusNode,
                  controller: _startingPoint,
                  onChanged: (val) {
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (val.isNotEmpty) {
                        autoCompleteSearch(val);
                      }
                      else {
                        setState(() {
                          predictions = [];
                          startPosition = null;
                        });
                      }
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "Enter your Location",
                      fillColor: Colors.white,
                      filled: true,
                    suffixIcon: _startingPoint.text.isNotEmpty ? IconButton(onPressed: () {
                      setState(() {
                        predictions = [];
                        _startingPoint.clear();
                      });
                    }, icon: Icon(Icons.clear_outlined),
                    ) : null,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          )
                      )
                  )
              ),


              SizedBox(height: 20.0,),
              TextFormField(
                  focusNode: endFocusNode,
                  controller: _endingPoint,
                  onChanged: (val) {
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      if (val.isNotEmpty) {
                        autoCompleteSearch(val);
                      }
                      else {
                        setState(() {
                          predictions = [];
                          endPosition = null;
                        });
                      }
                    });
                  },

                  decoration: InputDecoration(
                      labelText: "Destination",
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: _endingPoint.text.isNotEmpty ? IconButton(onPressed: () {
                        setState(() {
                          predictions = [];
                          _endingPoint.clear();
                        });
                      }, icon: Icon(Icons.clear_outlined),
                      ) : null
                    ,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          )
                      ),

                  )


              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.pin_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions[index].description.toString()),
                      onTap: () async {
                        final placeId = predictions[index].placeId!;
                        final details = await googlePlace.details.get(placeId);
                        if (details != null && details.result != null &&
                            mounted) {
                          if (startFocusNode.hasFocus) {
                            setState(() {
                              startPosition = details.result;
                              // print(details.result!.name.toString());
                              _startingPoint.text = details.result!.name!;
                              predictions = [];
                            });
                          }
                          else {
                            setState(() {
                              endPosition = details.result;
                              _endingPoint.text = details.result!.name!;
                              predictions = [];
                            });
                          }

                          if (startPosition != null && endPosition != null) {

                            Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(startPosition: startPosition, endPosition: endPosition)));
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
