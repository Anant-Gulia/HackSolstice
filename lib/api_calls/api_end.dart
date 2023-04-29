import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:brew_crew/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
const laptopId = " 192.168.1.8";
const String baseUrl = 'http://10.0.2.2:5300/';
// const String baseUrl = "http://192.168.1.8:5300/";


class baseClient {
  var client = http.Client();
  Future<dynamic> get(String api,String email_id,String passcode) async {
    /*
    api names
    -> /checkBalance
    -> /getcred
     */
    String take = "?email="+email_id+"&"+"pssk="+passcode;
    var url = Uri.parse(baseUrl + api + take);
    print(url);
    var response = await client.get(url);
    // print(response);
    return response;
  }

  Future<dynamic> getDet(String api,String email_id) async {
    /*
    api names
    -> /checkBalance
    -> /getcred
     */
    String take = "?email="+email_id;
    var url = Uri.parse(baseUrl + api + take);
    print(url);
    var response = await client.get(url);
    // print(response);
    return response;
  }


  Future<dynamic> getCost(String distance) async {

    String take = "?distance="+distance;
    String api = "getPrice";
    var url = Uri.parse(baseUrl + api + take);
    print(url);
    var response = await client.get(url);
    // print(response);
    return response;
  }

  Future<dynamic> prevoiusPayment(String accountNo) async {

    String take = "previousPayments?accountNo="+accountNo;
    var url = Uri.parse(baseUrl + take);
    print(url);
    var response = await client.get(url);
    // print(response);
    return response;
  }

  Future<dynamic> prevoiusPaymentDriver(String accountNo) async {

    String take = "previousPaymentsDriver?accountNo="+accountNo;
    var url = Uri.parse(baseUrl + take);
    print(url);
    var response = await client.get(url);
    // print(response);
    return response;
  }


  Future<dynamic> paymentGetReuest(String senderEmail,String senderPrivateKey, String senderAccount, String receiverAccount, String amount, String arrival, String dest, String driverName, String riderName) async {
    var url = Uri.parse(baseUrl+"payment"+"?senderEmail=$senderEmail&senderPrivateKey=$senderPrivateKey&senderAccount=$senderAccount&receiverAccount=$receiverAccount&amount=$amount&arrival=$arrival&dest=$dest&driverName=$driverName&riderName=$riderName");
    print(url);
    var response = await client.get(url);

    return response;

  }

  Future<dynamic> post(String api, String email,String passCode,String name, String mobNo, String isDriv) async {
    var url = Uri.parse(baseUrl+api);
    var BODY = jsonEncode(<String,String>{
      'email': email.toString(),
      "pssk": passCode.toString(),
      'name': name.toString(),
      'mobNo':mobNo.toString(),
      'isDriv': isDriv.toString()
    });

    var response = await client.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: BODY);
    // if(response.statusCode == 201){
    //
    // }
    return response;
  }


}