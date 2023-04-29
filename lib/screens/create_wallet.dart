import 'dart:convert';

import 'package:brew_crew/api_calls/api_end.dart';
import 'package:brew_crew/screens/alert_dialog.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:toggle_switch/toggle_switch.dart';


const List<Widget> work = <Widget>[
  Text('Rider'),
  Text('Driver'),
];


class createWallet extends StatefulWidget {

  const createWallet({Key? key}) : super(key: key);

  @override
  State<createWallet> createState() => _createWalletState();
}

class _createWalletState extends State<createWallet> {
  final AuthService _auth = AuthService();
  baseClient _bc = baseClient();
  late String email;
  String pssKey = "";
  String mobNo = "";
  String name = "";
  String error = "";
  var isDriv = 0;
  bool isCreated = false;
  int initialIndex = 0;
  final List<bool> _selectedWork = <bool>[true, false];

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser!.email!;
  }

  createWallet() async{
    var res = await _bc.post("createwallet", email, pssKey,name,mobNo,isDriv.toString());
    // var take = jsonDecode(res.body.toString());
    if(res.statusCode == 201){
      return "Account already exists";
    }
    else{
      return "Account created";
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Wallet"),
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0,),
                TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                    ],
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Enter a passkey' : null,
                    onChanged: (val) {
                      setState(() {
                        pssKey = val;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Passkey",
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 2.0,
                            )
                        )
                    )
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                    ],
                    keyboardType: TextInputType.name,
                    validator: (val) => val!.isEmpty ? 'Enter your Name' : null,
                    onChanged: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Name",
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 2.0,
                            )
                        )
                    )
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                    ],
                    validator: (val) => val!.isEmpty ? 'Enter your phone no.' : null,
                    onChanged: (val) {
                      setState(() {
                        mobNo = val;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Mob No.",
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 2.0,
                            )
                        )
                    )
                ),
                SizedBox(
                  height: 20.0,
                ),
            // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
            ToggleSwitch(
              initialLabelIndex: initialIndex,
              totalSwitches: 2,
              activeBgColor: [Colors.green],
              labels: ['Rider', 'Driver'],
              onToggle: (index) {
                print('switched to: $index');
                setState(() {
                  initialIndex = index!;
                  isDriv = initialIndex;
                });
              },
            ),

                SizedBox(height: 20.0,),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(
                      "Create",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                        print(name + " " + mobNo);
                        if(pssKey.isEmpty || pssKey.length > 4 || pssKey.length < 4){
                          setState(() {
                            isCreated = false;
                            error = "Enter a 4 digit passcode";
                          });
                        }
                        else if(name.isEmpty || mobNo.isEmpty || mobNo.length != 10){
                          setState(() {
                            isCreated = false;
                            error = "Please enter valid details";
                          });
                        }
                        else{
                            var res = await createWallet();
                            if(res == "Account already exists"){
                              setState(() {
                                isCreated = false;
                                error = "Account already exists";
                              });
                            }
                            else if(res == "Account created"){
                              print("widet.checkfunction called");

                              setState(() {
                                isCreated = true;
                                error = "Account created!";
                              });

                              Future.delayed(const Duration(milliseconds: 500), () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => alertDialog(),
                                );
                                Future.delayed(const Duration(milliseconds: 2500), () async {
                                  await _auth.signOut();
                                });

                              });

                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => alertDialog(),
                              );

                              // await _auth.signOut();
                              // Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                            }


                        }

                    },
                  ),
                ),
                SizedBox( height: 20.0),
                Text(
                  error,
                  style: TextStyle(color: isCreated? Colors.green : Colors.red, fontSize: 14.0),
                )

              ],
            ),
          ),
        ),
      )
    );
  }
}
