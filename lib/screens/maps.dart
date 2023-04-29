import 'package:flutter/material.dart';

class GoogMap extends StatefulWidget {
  const GoogMap({Key? key}) : super(key: key);

  @override
  State<GoogMap> createState() => _GoogMapState();
}

class _GoogMapState extends State<GoogMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('You way'),
      ),
    );
  }
}
