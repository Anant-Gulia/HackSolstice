import 'dart:convert';

import 'package:brew_crew/screens/previousPaymentsDriver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../api_calls/api_end.dart';
import '../check_balance.dart';
import '../create_wallet.dart';
import '../get_credentials.dart';
import '../prevPayments.dart';
import '../testScreens/imageUpload.dart';

class CustomDrawer extends StatefulWidget {
  final bool? isDriver;
  const CustomDrawer({Key? key, this.isDriver}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String name = "";
  baseClient _bc = baseClient();
  String email = "";
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    email = FirebaseAuth.instance.currentUser!.email!;
    setName();
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
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 180,
            child:  DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding:  EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Text('Ethereum Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400,fontSize: 21.0))
                  ),
                  Text('$name', style: TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w400))

                ],
              ),
            ),
          ),

          ListTile(
            title: const Text('Create Wallet',   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => createWallet()));
            },
          ),
          ListTile(
            title: const Text('Check Balance',   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => checkBalance()));
            },
          ),
          ListTile(
            title: const Text('Get your credentials',  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => getCredentials()));
            },
          ),
          ListTile(
            title: const Text('Previous Payments', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => widget.isDriver! ? prevPayDriver() : prevPay()));
            },
          ),
          // ListTile(
          //   title: const Text('Testing'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => image_upload()));
          //   },
          // ),
        ],
      ),
    );
  }
}
