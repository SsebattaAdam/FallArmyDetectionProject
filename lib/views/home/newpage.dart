
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../common/app_style.dart';
import '../../common/back_ground_container.dart';
import '../../common/reusable_textwidget.dart';
import '../../constants/constants.dart';
import '../../constants/uidata.dart';

class Newpagetobedefined extends StatelessWidget {
  const Newpagetobedefined({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .3,
          backgroundColor: kPrimary,
        title: ReusableTextwidget(text: 'FirstPage', style: appStyle(36, kPrimaryLight, FontWeight.w600))
      ),
      body: BackGroundContainer(

        color: Colors.white,
        child: Padding(
          padding:  EdgeInsets.all(12.h),
          child: ListView(
            scrollDirection: Axis.vertical,




          ),
        )
        ,)

    );
  }
}
