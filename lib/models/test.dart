
// import 'dart:convert';
//
// import '../api_calls/api_end.dart';
// import '../services/auth.dart';
//
// class test1 {
//   baseClient _bc = baseClient();
//   final AuthService _auth = AuthService();
//   Stream<String> get status {
//     var res = await _bc.getDet("isDriver", email);
//     var take = jsonDecode(res.body.toString());
//     String status =  take["isDriver"].toString();
//     return status;
//   }
// }