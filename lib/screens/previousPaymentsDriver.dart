import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../api_calls/api_end.dart';

class prevPayDriver extends StatefulWidget {
  const prevPayDriver({Key? key}) : super(key: key);

  @override
  State<prevPayDriver> createState() => _prevPayDriverState();
}

class _prevPayDriverState extends State<prevPayDriver> {
  List<DataRow> _rowList = [

  ];
  late String email;
  baseClient _bc = baseClient();
  String pssKey = "";
  bool showOkay = true;
  bool showPayments = false;
  Widget payments = Text("");

  prevPayments() async {
    print("inoked");
    var res = await _bc.get("getCred", email, pssKey);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    String accountAddress = take["accountNum"];
    var paymentsData = await _bc.prevoiusPayment(accountAddress);
    // List<Widget> ls = List<>();
    var jsonPayments = jsonDecode(paymentsData.body.toString());
    print(" fqwff ${jsonPayments["transfers"]}");
    for(var v in jsonPayments["transfers"]){
      print("from = ${v["from"]}");
      print("to = ${v["to"]}");
    }


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
  Future<Widget> loadWidget() async{
    var res = await _bc.get("getCred", email, pssKey);
    // var out = (res.body);
    var take = jsonDecode(res.body.toString());
    String accountAddress = take["accountNum"];
    if(accountAddress == "wrong_password"){
      setState(() {
        showPayments = false;
      });
      return Text("Wrong passCode", style: TextStyle(color: Colors.red),);
    }

    var paymentsData = await _bc.prevoiusPaymentDriver(accountAddress);

    var jsonPayments = jsonDecode(paymentsData.body.toString());
    print(jsonPayments);
    //
    List <Widget> gameCells = <Widget>[];
    // List items = [];
    for(var rides in jsonPayments){
      // print("cost = " + rides["cost"]);
      double totCost = double.parse(rides["cost"]);
      int rPrice =  ((totCost/(0.0005248792777661) * 80) + 30).round();
      var rupeeCost = rPrice.toString();
      gameCells.add(
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.car_rental_rounded),
                  tileColor: Colors.green,
                  title: Text('Arrival', style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w400)),
                  subtitle: Text("${rides["arrival"]}", style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.drive_eta_rounded),
                  tileColor: Colors.green,
                  title: Text('Destination',style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w400)),
                  subtitle: Text("${rides["destination"]}", style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.money),
                  title: Text('Fare',style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w400)),
                  tileColor: Colors.green,
                  trailing: Text("${rides["cost"]} eth ~ $rupeeCost ₹ ", style: TextStyle(fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.wallet_rounded),
                  title: Text('From',style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w400)),
                  tileColor: Colors.green,
                  trailing: Text("${rides["riderName"]}", style: TextStyle(fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Driver Name',style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w400)),
                  tileColor: Colors.green,
                  trailing: Text("${rides["driverName"]}", style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.indeterminate_check_box_sharp,),
                  title: Text('Driver Account No.',style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w400)),
                  tileColor: Colors.green,
                  subtitle: Text("${rides["toAcc"]}", style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.timer),
                  tileColor: Colors.green,
                  title: Text('Time',style: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.bold)),
                  subtitle: Text("${rides["time"]}", style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w400),),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle),
                  tileColor: Colors.green,
                  title: ElevatedButton(
                    onPressed: () => {
                      print("${rides["url"]}"),
                      _launchUrl("${rides["url"]}")
                    }
                    , child: Text("Verify", style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w400)),style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  ),
                ),
                SizedBox(height: 10.0,)
              ],
            ),
          )
      );
      // // gameCells.add(Text("To : ${v["to"]}"));
      // // gameCells.add(SizedBox(height: 5.0,));
      // // gameCells.add(Text("Amount : ${v["value"]} eth"));
      // // gameCells.add(SizedBox(height: 9.0,));
      // // print("from = ${v["from"]}");
      // // print("to = ${v["to"]}");
    }





    return Column(
      children: gameCells.reversed.toList(),
    );

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
          title: const Text("Previous Payments" , style: TextStyle(fontWeight: FontWeight.w400) ),
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
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Enter a passkey' : null,
                      onChanged: (val) {
                        setState(() {
                          pssKey = val;
                        });
                      },
                      decoration: InputDecoration(
                          labelText: "Passkey for DRIVER",
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2.0,
                              )
                          )
                      )
                  ) ,
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
                        print("inoked!");
                        payments = await loadWidget();
                        setState(() {
                          showPayments = true;
                        });
                      },
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  showPayments ? payments : Text("")


                ],
              ),
            ),
          ),
        )

    );
  }
}
