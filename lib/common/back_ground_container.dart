import 'package:flutter/cupertino.dart';

import '../constants/constants.dart';


class BackGroundContainer extends StatelessWidget {
  const BackGroundContainer({super.key, required this.child, required this.color});

  final Widget  child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [kPrimary, kSecondary],
        color: color,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20)
        ),
        // image: DecorationImage(image: AssetImage('assets/images/restaurant_bk.png'),
        //     fit: BoxFit.cover,
        //   opacity: .7
        // )
      ),
      child: child,
    );
  }
}
