import 'dart:convert';
import 'dart:math';

import 'package:brew_crew/Api_keys/googleMapApiKey.dart';
import 'package:brew_crew/screens/Select_driver.dart';
import 'package:brew_crew/screens/maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

import '../api_calls/api_end.dart';
import '../map_utils.dart';

List cars = [
  {'id': 0, 'name': 'Select a ride', 'price': "0"},
  {'id': 3, 'name': 'Cab', 'price': "0"},
];

var autoMilage = 30;
var carMilage = 12;

class MapScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  const MapScreen({Key? key, this.startPosition, this.endPosition})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  baseClient _bc = baseClient();
  late String totDistance;
  late CameraPosition _initialPosition;
  late double lat1;
  late double lon1;
  late double lat2;
  late double lon2;
  late double autoPrice;
  late double carPrice;
  late double PetrolPrice;
  String rupeesPrice = "";
  String totalCost = "";
  double basePrice = 50;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  int selectedCardId = 1;
  @override
  void initState() {
    super.initState();
    // print(  " my location is " + widget.startPosition.toString());
    // print("misc = " + widget.toString());
    lat1 = widget.startPosition!.geometry!.location!.lat!;
    lon1 = widget.startPosition!.geometry!.location!.lng!;
    lat2 = widget.endPosition!.geometry!.location!.lat!;
    lon2 = widget.endPosition!.geometry!.location!.lng!;
    _initialPosition = CameraPosition(
        target: LatLng(widget.startPosition!.geometry!.location!.lat!,
            widget.startPosition!.geometry!.location!.lng!),
        zoom: 8);
        totDistance = double.parse(calculateDistance(lat1, lon1, lat2, lon2).toStringAsFixed(2)).toString() ;
        priceCalculator();
        // autoPrice = priceCalculator("auto");
        // carPrice = priceCalculator("cab");
    priceCalculator();
  }

  priceCalculator() async{

    var response = await _bc.getCost(totDistance);
    var jsonResponse = jsonDecode(response.body.toString());

    // print(jsonResponse["cost"]);
    setState(() {
      totalCost = jsonResponse["cost"];
      double totCost = double.parse(totalCost);
      int rPrice =  ((totCost/(0.0005248792777661) * 80) + 30).round();
      rupeesPrice = rPrice.toString();
      print("rupee cost = " + rupeesPrice);
    });
  }
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1.6093;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 3);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        myGoogleApikey,
        PointLatLng(widget.startPosition!.geometry!.location!.lat!,
            widget.startPosition!.geometry!.location!.lng!),
        PointLatLng(widget.endPosition!.geometry!.location!.lat!,
            widget.endPosition!.geometry!.location!.lng!),
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> _markers = {
      Marker(
          markerId: MarkerId('Start'),
          position: LatLng(widget.startPosition!.geometry!.location!.lat!,
              widget.startPosition!.geometry!.location!.lng!),
          infoWindow: InfoWindow(title: 'Start')),
      Marker(
          markerId: MarkerId('End'),
          position: LatLng(widget.endPosition!.geometry!.location!.lat!,
              widget.endPosition!.geometry!.location!.lng!),
          infoWindow: InfoWindow(title: 'End'))
    };
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: CircleAvatar(
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(children: [
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            height: constraints.maxHeight / 2,
            child: GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: _initialPosition,
              markers: Set.from(_markers),
              onMapCreated: (GoogleMapController controller) {
                Future.delayed(Duration(milliseconds: 2000), () {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      MapUtils.boundsFromLatLngList(
                          _markers.map((loc) => loc.position).toList()),
                      1));
                  _getPolyline();
                });
              },
            ),
          );
        }),
        DraggableScrollableSheet(
          snap: true,
            snapSizes: [0.5,1],
            initialChildSize: 0.5,
            minChildSize: 0.5,
            builder: (context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  controller: scrollController,
                  itemCount: cars.length,
                  itemBuilder: (BuildContext context, int index){
                    final car = cars[index];
                    if(index == 0){
                      return Padding(padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Divider(thickness: 5),
                            ),
                            Text('Choose a trip for your $totDistance km ride', style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500 ),),
                          ]
                        ),
                      );
                    }
                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        onTap: () {
                          setState(() {
                           selectedCardId = car['id'];
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => selectDriver(userLat: lat1.toString(), userLong: lon1.toString(),cost: totalCost,arrival: widget.startPosition!.name, dest: widget.endPosition!.name  )));
                        },
                        leading: Icon(Icons.car_rental),
                        title: Text(car['name'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),),
                        trailing: Text("${totalCost} eth or ${rupeesPrice} ₹", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
                        selected: selectedCardId == car['id'],
                        selectedTileColor: Colors.grey[200],
                      ),
                    );
                  },
                ),
              );
            })
      ]),
    );
  }
}
