import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  _EmptyStateState createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          SvgPicture.asset(
            'assets/svgs/paddy_smiley.svg',
            height: 75,
            width: 75,
            color: colors.paddygreen,
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: textControl("Nothing to see here.", context,
                size: 15,
                color: colors.paddygreen,
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}
