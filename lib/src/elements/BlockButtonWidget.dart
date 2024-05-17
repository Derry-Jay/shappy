import 'package:flutter/material.dart';

class BlockButtonWidget extends StatelessWidget {
  const BlockButtonWidget(
      {Key key,
      @required this.color,
      @required this.text,
      @required this.onPressed})
      : super(key: key);

  final Color color;
  final Text text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: this.color.withOpacity(0.4),
              blurRadius: 0,
              offset: Offset(0, 0)),
          BoxShadow(
              color: this.color.withOpacity(0.4),
              blurRadius: 0,
              offset: Offset(0, 0))
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: FlatButton(
        onPressed: this.onPressed,
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 30,
            vertical: MediaQuery.of(context).size.height / 60),
        color: this.color,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0)),
        child: this.text,
      ),
    );
  }
}
