import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  String message;
  ProgressDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6)
        ),
        child: Row(
          children: [
            SizedBox(width: 6),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
            SizedBox(width: 26),
            Text(
              message,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),

    );
  }
}
