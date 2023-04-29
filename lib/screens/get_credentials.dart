import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api_calls/api_end.dart';

class getCredentials extends StatefulWidget {
  const getCredentials({Key? key}) : super(key: key);

  @override
  State<getCredentials> createState() => _getCredentialsState();
}

class _getCredentialsState extends State<getCredentials> {
  bool isCreated = false;
  String pssKey = "";
  String email = "";
  String accountNumber = "";
  String mnemonix = "";
  String privateKey = "";
  baseClient _bc = baseClient();


  getCreds() async{

    var res = await _bc.get("getCred", email, pssKey);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    Map<String,String> creds = HashMap();
    creds.addAll({ 'accountNum' : take["accountNum"], 'privateKey' : take["privateKey"] } );
    return creds;
  }

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Account info", style: TextStyle(fontWeight: FontWeight.w400)),
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
        body: Container(
          padding: EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0,),
                TextFormField(
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
                              color: Colors.green,
                              width: 2.0,
                            )
                        )
                    )
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 50,
                  width: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(
                      "Okay",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                    onPressed: () async {
                      if(pssKey.isEmpty || pssKey.length > 4 || pssKey.length < 4){
                        setState(() {
                          isCreated = false;
                          accountNumber = "Enter a 4 digit passcode";
                          privateKey = "";
                        });
                        return;
                      }
                      Map<String, String> res =  HashMap();
                      res.addAll(await getCreds());
                      print(res);
                      if(res["accountNum"] == "error"){
                        setState(() {
                          isCreated = false;
                          accountNumber = "Server side error :(";
                          privateKey = "";
                        });
                      }
                      else if(res["accountNum"] == "wrong_password"){
                        setState(() {
                          isCreated = false;
                          accountNumber = "Wrong password";
                          privateKey = "Wrong password";
                        });
                      }
                      else{
                        setState(() {
                          isCreated = true;
                          accountNumber = "${res["accountNum"]}";
                          privateKey =    "${res["privateKey"]}";
                        });
                      }

                    },
                  ),
                ),
                SizedBox(height: 20.0,),
                Expanded(child: Container(
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                             ListTile(
                              title: Text('Account Number',style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.white),),
                               tileColor: Colors.green,
                              subtitle: Text("$accountNumber", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: Colors.white),),
                            ),
                            ListTile(
                              tileColor: Colors.green,
                              title: Text('Hash key' ,style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.white)),
                              subtitle: Text("$privateKey" ,style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: Colors.white),),
                            )

                          ],
                        ),
                      ),
                      // Text(
                      //   accountNumber,
                      //   style: TextStyle(color: isCreated? Colors.black : Colors.red, fontSize: 18.0),
                      // ),
                      // SizedBox(height: 20.0,),
                      // Text(
                      //   privateKey,
                      //   style: TextStyle(color: Colors.black, fontSize: 18.0),
                      // )
                    ],
                  ),
                ))

              ],
            ),
          ),
        )
    );
  }
}
