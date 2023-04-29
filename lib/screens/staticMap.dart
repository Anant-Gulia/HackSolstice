import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class statMap extends StatefulWidget {
  const statMap({Key? key}) : super(key: key);

  @override
  State<statMap> createState() => _statMapState();
}

class _statMapState extends State<statMap> {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ))
        ],
      ),
    );
  }
}


