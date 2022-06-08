import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentPaddyLogo extends StatelessWidget {

  final Widget svg = SvgPicture.asset(
    'assets/svgs/student_paddy_logo.svg',
    height: 90,
  );

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerLeft, child: Container(child: svg));
  }
}