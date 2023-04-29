import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../api_calls/api_end.dart';

class checkBalance extends StatefulWidget {
  const checkBalance({Key? key}) : super(key: key);

  @override
  State<checkBalance> createState() => _checkBalanceState();
}

class _checkBalanceState extends State<checkBalance> {
  bool isCreated = false;
  baseClient _bc = baseClient();
  String pssKey = "";
  String email = "";
  String balance = "";
  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser!.email!;
  }


  checkBalance() async{
    var res = await _bc.get("checkBalance", email, pssKey);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    var Bal = double.parse(take["message"]);
    print("Bal = $Bal");
    Bal = Bal/(pow(10, 17));
    return Bal.toStringAsFixed(5);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check Balance" , style: TextStyle(fontWeight: FontWeight.w400)),
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
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if(pssKey.isEmpty || pssKey.length > 4 || pssKey.length < 4){
                        setState(() {
                          isCreated = false;
                          balance = "Enter a 4 digit passcode";
                        });
                        return;
                      }

                      var result = await checkBalance();
                      if(result == "wrong_password"){
                        setState(() {
                          isCreated = false;
                          balance = "Wrong passcode";
                        });
                        return;
                      }
                      else if(result == "error"){
                        setState(() {
                          isCreated = false;
                          balance = "Server side error :(";
                        });
                        return;
                      }
                      else{
                        setState(() {
                          isCreated = true;
                          balance = "Balance: $result eth.";
                        });
                        return;
                      }
                      // if(result == "false"){
                      //   setState(() {
                      //     balance = "Wrong Password";
                      //   });
                      // }
                      // else{
                      //   setState(() {
                      //     balance = "Your balance is " + result.toString() +" eth";
                      //   });
                      // }

                    },
                  ),
                ),
                SizedBox( height: 20.0),
                Text(
                  balance,
                  style: TextStyle(color: isCreated? Colors.green : Colors.red, fontSize: 20.0),
                )

              ],
            ),
          ),
        )

    );
  }
}
