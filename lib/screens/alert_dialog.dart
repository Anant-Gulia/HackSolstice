import 'package:flutter/material.dart';

class alertDialog extends StatelessWidget {
  const alertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('You are going to be logged out.'),
      content: const Text('Please Sign In again.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
