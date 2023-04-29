import 'dart:collection';
import 'dart:convert';

import 'package:brew_crew/screens/home/mainHomeRoute.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_calls/api_end.dart';
import '../services/auth.dart';

class payUser extends StatefulWidget {
  final String? accountAddress;
  final String? cost;
  final String? arrival;
  final String? dest;
  final String? driverName;
  const payUser({Key? key, required this.accountAddress, this.cost, this.arrival, this.dest, this.driverName}) : super(key: key);

  @override
  State<payUser> createState() => _payUserState();
}

class _payUserState extends State<payUser> {
  String pssKey = "";
  final AuthService _auth = AuthService();
  baseClient _bc = baseClient();
  String email = "";
  String paymentHash = "";
  bool showPayButton = true;
  bool showFutureBuilder = false;
  String riderName = "";
  _paymentFunc() async {

    print("cost = ${widget.cost}");
    var senderDetails = await _bc.get("getCred", email, pssKey);
    var senderDet = jsonDecode(senderDetails.body.toString());

    print(senderDet["privateKey"]);
    var res = await _bc.paymentGetReuest(
      email,
      senderDet["privateKey"],
      senderDet['accountNum'],
      widget.accountAddress.toString(),
      widget.cost.toString(),
      widget.arrival.toString(),
      widget.dest.toString(),
      widget.driverName.toString(),
      riderName
    );


  }

  void setName() async{
    var res = await _bc.getDet("nameMob", email);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    if(take["name"] == "no_account"){
      setState(() {
        riderName = "Please create your wallet";
      });
    }
    else {
      setState(() {
        riderName = take["name"].toString() + "\'s wallet";
      });
    }
  }

  Future<Widget> loadWidget() async  {

    print("cost = ${widget.cost}");
    var senderDetails = await _bc.get("getCred", email, pssKey);
    var senderDet = jsonDecode(senderDetails.body.toString());

    print(senderDet["privateKey"]);
    var res = await _bc.paymentGetReuest(
      email,
      senderDet["privateKey"],
      senderDet['accountNum'],
      widget.accountAddress.toString(),
      widget.cost.toString(),
      widget.arrival.toString(),
      widget.dest.toString(),
      widget.driverName.toString(),
      riderName
    );
    var take = jsonDecode(res.body.toString());
    print(take.toString());
    if(take["hash"] == "wrong_password"){
      return Text("Wrong passcode", style: TextStyle(color: Colors.red),);
    }
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                width: 130,
                child: ElevatedButton(onPressed: () {
                  _launchUrl("https://goerli.etherscan.io/tx/${take["hash"]}");
                }, child: Text("Verify"),style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
              ),
              SizedBox(height: 20.0,),
              SizedBox(
                height: 50,
                width: 130,
                child: ElevatedButton(onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                      HomePage()), (Route<dynamic> route) => false);
                }, child: Text("Next"), style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),),
              )

            ],
          ),
        )
      ],
    );
  }

  Future<void> _launchUrl(String url) async{
    print(url);
    if(await canLaunch(url)){
      await launch(url);
    }else {
      throw 'Could not launch $url';
    }
    // final Uri uri = Uri(scheme: "https", host: url);
    // print(url);
    // if(!await launchUrl(
    //   uri,
    //   mode : LaunchMode.externalApplication,
    // )) {
    //   throw "Cannot launch url";
    // }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = FirebaseAuth.instance.currentUser!.email!;
    setName();
    print(widget.accountAddress);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
        AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          title: const Text("Pay" , style: TextStyle(fontWeight: FontWeight.w400)),
          backgroundColor: Colors.green,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: [
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
                                color: Colors.green,
                                width: 2.0,
                              )
                          )
                      )
                  ),
                  SizedBox(height: 20.0,),
                   showPayButton ? SizedBox(
                     height: 50,
                     width: 130,
                     child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          setState(() {
                            showPayButton = false;
                          });
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {
                              showFutureBuilder = true;
                            });
                          });
                        },
                        child: Text("Pay", style: TextStyle(color: Colors.white),)
                  ),
                   ) : Text(""),
                  SizedBox(height: 20.0,),
                  Column(
                    children: [
                      showFutureBuilder ? FutureBuilder(
                        future: loadWidget(),
                        builder: (BuildContext context, AsyncSnapshot<Widget> widget){
                          if(!widget.hasData){
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return widget.data!;
                        },
                      ) : Text(""),

                    ],
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
