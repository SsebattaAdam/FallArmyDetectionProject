import 'package:fammaize/common/reusable_textwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/constants.dart';
import 'app_style.dart';


class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 110.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      color: kOffWhite,
      child: Container(
        margin: EdgeInsets.only(top: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
          crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: Color(0xFF2E7D32),
                  backgroundImage:const NetworkImage(
                    "https://images.unsplash.com/photo-1567306226416-28f0efdc88ce",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h, left: 8.w),
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextwidget(text: 'Detect Now', style: appStyle(13, kSecondary, FontWeight.w600),),
                      SizedBox(
                        width: width * 0.65,
                        child: Text('Adam Bell ',
                          overflow: TextOverflow.ellipsis,
                          style: appStyle(11, kDark, FontWeight.normal),),
                      ),

                    ],
                  ),
                )
              ],
            ),
             Text(
              getTeimeOfDay()
              , style: const TextStyle(fontSize: 35),
            )
          ],
        ),
      ),
    );
  }

  String getTeimeOfDay() {
    var hour = DateTime.now().hour;
    if (hour >=0  && hour< 12) {
      return '🌞';
    }
    if (hour >=12 && hour< 16) {
      return '☀️';
    }
    return '🌙';
  }
}
