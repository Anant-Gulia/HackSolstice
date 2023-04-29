import 'dart:convert';

import 'package:brew_crew/screens/Payments.dart';
import 'package:brew_crew/screens/driverHome.dart';
import 'package:brew_crew/screens/home/home2.dart';
import 'package:brew_crew/screens/mapScreen.dart';
import 'package:brew_crew/screens/maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../api_calls/api_end.dart';
import 'home.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  baseClient _bc = baseClient();
  String email = "";
  var done = false;
  var isDriver = false;


  Future<Widget> loadWidget() async  {
    var res = await _bc.getDet("isDriver", email);
    var take = jsonDecode(res.body.toString());
    String status =  take["isDriver"].toString();
    print("status = " + status);
    if(status == "0"){
      return Home2();
    }
    else{
      return driverScreen();
    }
  }

  //   Future<bool> _checkDriver() async {
  //   var res = await _bc.getDet("isDriver", email);
  //   // var out = (res.body);
  //   var take = jsonDecode(res.body.toString());
  //   String status =  take["isDriver"].toString();
  //   print("status = " + status);
  //
  //     if(status == "0"){
  //       // setState(() {
  //       //   isDriver = false;
  //       // });
  //       return false;
  //
  //     }
  //     else{
  //       // setState(() {
  //       //   isDriver = true;
  //       // });
  //       return true;
  //
  //     }
  //
  // }


  @override
  void initState() {
    // TODO: implement initState
    email = FirebaseAuth.instance.currentUser!.email!;
    super.initState();
    print(isDriver);
  }



  @override
  Widget build(BuildContext context) {
      
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Main app',
        home: FutureBuilder(
          future: loadWidget(),
          builder: (BuildContext context, AsyncSnapshot<Widget> widget){
            if(!widget.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return widget.data!;
          },
        ),
      );


      

      // return MaterialApp(
      //   title: 'Main app',
      //   initialRoute: '/',
      //   routes: {
      //     '/' : (context) =>  Home2(check: _checkDriver),
      //     '/maps' : (context) => MapScreen(),
      //     '/payment' : (context) =>  DaPayment(),
      //     '/driver' : (context) => driverScreen(),
      //
      //
      //   },
      // );

  }
}
