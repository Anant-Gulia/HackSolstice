import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/screens/authenticate/authenticate.dart';
import 'package:brew_crew/screens/home/home.dart';
import 'package:brew_crew/screens/home/mainHomeRoute.dart';
import 'package:brew_crew/screens/maps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    //return either home or authenticate
      if (user == null){
        return Authenticate();
      }
      else{
        return HomePage();
        // return MaterialApp(
        //   title: 'Main app',
        //   initialRoute: '/',
        //   routes: {
        //     '/' : (context) => const GoogMap(),
        //
        //   },
        // );
        // return Home();
      }
  }
}
