import 'dart:collection';
import 'dart:convert';

import 'package:brew_crew/screens/componenetsReusable/drawer.dart';
import 'package:brew_crew/screens/prevPayments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../api_calls/api_end.dart';
import '../services/auth.dart';
import 'check_balance.dart';
import 'create_wallet.dart';
import 'get_credentials.dart';

class driverScreen extends StatefulWidget {
  const driverScreen({Key? key}) : super(key: key);
  @override
  State<driverScreen> createState() => _driverScreenState();
}

class _driverScreenState extends State<driverScreen> {
  final database = FirebaseDatabase.instance.reference();
  bool light = false;
  String status = "Offline";
  String email = "";
  String name = "";
  final AuthService _auth = AuthService();
  baseClient _bc = baseClient();


  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error("Location services are not enabled");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Location permission is denied");
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error("Location permission are permanently denied");
    }
    return await Geolocator.getCurrentPosition();
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




  void changeStatusToOffline() async{
    var key = "";
    for(var c in email.characters){
      if(c != '.'){
        key = key + c;
      }
    }
    await database.child('driverList').child(key).remove();
  }

  @override
  void initState() {
    // TODO: implement initState
    email = FirebaseAuth.instance.currentUser!.email!;
    super.initState();
    setName();

  }

  getCreds() async{

    var res = await _bc.getDet("getcredwithout", email);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    Map<String,String> creds = HashMap();
    creds.addAll({ 'accountNum' : take["accountNum"]} );
    return creds;
  }


  @override
  Widget build(BuildContext context) {
    final DriverRef = database. child('driverList/');

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Driver"),
          backgroundColor: Colors.green,
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () async {
                  if(light == true){
                    changeStatusToOffline();
                  }
                  Future.delayed(const Duration(milliseconds: 2000), () async {
                    await _auth.signOut();
                  });
                },
                icon: Icon(Icons.person),
                label: Text("logout")),
          ],
        ),
        drawer: CustomDrawer(isDriver: true,),
        body: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Your status is $status",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 20, //<-- SEE HERE
                  ),
                  Switch(
                    // This bool value toggles the switch.
                    value: light,
                    activeColor: Colors.green,
                    onChanged: (bool value) async {

                      setState(() {
                        if(value == true){
                          status = "online";
                        }
                        else{
                          status = "offline";
                        }
                        light = value;
                      });

                        print("written!");
                        try {

                          if(value == true) {

                            print("started");
                            var res = await getCurrentLocation();
                            var lat = "";
                            var long = "";
                            if(res.latitude != null && res.longitude != null){
                              lat = res.latitude.toString();
                              long = res.longitude.toString();
                            }

                            Map<String, String> accounts =  HashMap();
                            accounts.addAll(await getCreds());


                            final nextDriver = <String, dynamic>{
                              'name': "Aviral",
                              'rating': "4.5",
                              'lat' : '${lat}',
                              'long' : '${long}',
                              'accNo':'${accounts["accountNum"]}',
                              'time': DateTime
                                  .now()
                                  .millisecondsSinceEpoch
                            };
                            var key = "";
                            for(var c in email.characters){
                              if(c != '.'){
                                key = key + c;
                              }
                            }

                            await database.child('driverList').child(key).set(
                                nextDriver);
                          }
                          else{
                            changeStatusToOffline();
                          }

                          print("ended");
                        }
                        catch(error){
                          throw error;
                        }

                    },
                  )
                ],
              ),



            ],
          ),

          ));
  }
}
