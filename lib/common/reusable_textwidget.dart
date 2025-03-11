import 'package:flutter/cupertino.dart';

class ReusableTextwidget extends StatelessWidget {
  const ReusableTextwidget({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    return Text(
      maxLines: 1,
      softWrap: false,
      textAlign: TextAlign.left,
      text,
      style: style,
    );
  }
}
