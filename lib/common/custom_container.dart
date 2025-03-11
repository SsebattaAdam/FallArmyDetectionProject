import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/constants.dart';


class CustomContainer extends StatelessWidget {
   CustomContainer({super.key,required this.containerContent});

  Widget containerContent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      width:  width,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
           // topLeft: Radius.circular(30.r),
           // topRight: Radius.circular(30.r),
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        child: Container(
          width: width,
          color: kOffWhite,
          child: SingleChildScrollView(
            child: containerContent,
          )
        ),
        )
      );
  }
}
