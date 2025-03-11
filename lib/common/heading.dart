import 'package:fammaize/common/reusable_textwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';


import '../constants/constants.dart';
import 'app_style.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.text, this.onTapp});
  final String text;

 final void Function()? onTapp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(padding: EdgeInsets.only(top: 10.h),
            child: ReusableTextwidget(text: text , style: appStyle(16, kDark, FontWeight.bold)),
          ),

          GestureDetector(
            onTap: onTapp,
            child: Icon(AntDesign.appstore_o, color: kSecondary, size: 20.sp,),
          )

        ],
      ),
    );
  }
}
