

import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle appStyle(double size, Color color, FontWeight fw) {
  return GoogleFonts.poppins(
    fontSize: size.sp,
    color: color,
    fontWeight: fw,
  );
}