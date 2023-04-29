import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:brew_crew/screens/pay_user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import 'create_wallet.dart';

class selectDriver extends StatefulWidget {
  final String? userLat;
  final String? userLong;
  final String? cost;
  final String? arrival;
  final String? dest;
  const selectDriver({Key? key,  this.userLat,  this.userLong, this.cost, this.arrival, this.dest}) : super(key: key);

  @override
  State<selectDriver> createState() => _selectDriverState();
}

class _selectDriverState extends State<selectDriver> {
  final _database = FirebaseDatabase.instance.reference();
  final AuthService _auth = AuthService();
  late StreamSubscription _driverListStream;
  String distFromUser = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activateListeners();
  }
  void deactivate() {
    _driverListStream.cancel();
    super.deactivate();
  }
  void _activateListeners(){
    _driverListStream = _database.child('driverList').onValue.listen((event) {
      Object? map = event.snapshot.value;

      var res = event.snapshot.value;
      // var out = (res.body);
      var take = jsonDecode(res.toString());
      print(take);
    });
  }

  double calculateDistance(lat1S, lon1S, lat2S, lon2S){
    double lat1 = double.parse(lat1S);
    double lon1 = double.parse(lon1S);
    double lat2 = double.parse(lat2S);
    double lon2 = double.parse(lon2S);
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1.6093;
  }

  String calculateDistanceBuilder(String lat, String long){
    print(widget.userLat);
    print(widget.userLong);
    print(lat);
    print(long);
    return double.parse( calculateDistance(widget.userLat, widget.userLong,lat, long).toString()).toStringAsFixed(2).toString();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        title: Text("Available Drivers"),
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      body:
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            children: [
              // StreamBuilder(stream: _database.child('driverList').orderByKey().limitToLast(10).onValue, builder: (context, snapshot) {
              //   final titlesList = <ListTile>[];
              //   if(snapshot.hasData) {
              //     print(snapshot.data!.snapshot.value.toString());
              //     final myDirvers = Map<String, dynamic>.from(
              //         snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
              //
              //     if(myDirvers.isNotEmpty){
              //       for(var v in myDirvers.values){
              //         final driverTile = ListTile(
              //           leading: Icon(Icons.account_circle_rounded),
              //           title: Text(v["name"]),
              //           subtitle: Text(v["mobNo"] + " " + v["lat"] + " " + v["long"]),
              //
              //         );
              //         titlesList.add(driverTile);
              //     }
              //
              //     }
              //   }
              //   return Expanded(
              //       child:  titlesList.length == 0 ? Text("Currenly No riders available") : ListView(
              //     children:  titlesList,
              //   )
              //   );
              // }
              //
              // ) ,
              Flexible(
                child: FirebaseAnimatedList(
                  shrinkWrap: true,
                    query: _database.child('driverList/'),
                    itemBuilder: (BuildContext context,
                    DataSnapshot snapshot,
                        Animation<double> animation,
                        int index
                    ){

                    
                      return new ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => payUser(accountAddress: (snapshot.value as Map<dynamic,dynamic>)['accNo'].toString(), cost: widget.cost, arrival: widget.arrival, dest: widget.dest, driverName : (snapshot.value as Map<dynamic,dynamic>)['name'].toString() )));
                        },
                        leading: Icon(Icons.account_circle_rounded) ,
                        title: new Text("${(snapshot.value as Map<dynamic,dynamic>)['name'].toString()}"),
                        subtitle: new Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(height: 5.0,),
                            Text("${(snapshot.value as Map<dynamic,dynamic>)['rating'].toString()}")
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min ,
                          children: <Widget>[
                            Text("${calculateDistanceBuilder((snapshot.value as Map<dynamic,dynamic>)['lat'].toString(),(snapshot.value as Map<dynamic,dynamic>)['long'].toString() )} km away")
                          ],
                        ),
                      );
                    }

                ),
              )

            ],
          ),
        ),
      ),

    );
  }
}
