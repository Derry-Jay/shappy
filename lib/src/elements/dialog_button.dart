import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  int _stars = 0;

  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        Icons.star,
        size: 40.0,
        color: _stars >= starCount ? Colors.red : Colors.grey,
      ),
      onTap: () {
        setState(() {
          _stars = starCount;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 350,
        child: Column(
          children: [
            Text(
              'Order #34256376',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(
              height: 5,
            ),
            Text('Annachi kadai'),
            SizedBox(
              height: 5,
            ),
            Text(
              '20 Nov 2020',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildStar(1),
                _buildStar(2),
                _buildStar(3),
                _buildStar(4),
                _buildStar(5),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                labelText: 'Write a review',
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: RaisedButton(
                color: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
