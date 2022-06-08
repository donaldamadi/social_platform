import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ModalSheetBar extends StatelessWidget {
  /// Widget shown at top of bottom modal sheet

  final dynamic page;
  final bool extension;
  final String text;
  ModalSheetBar({required this.text, this.extension = false, this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                  child: Icon(Icons.chevron_left, color: extension ? Colors.white : Colors.transparent),
                  onTap: () {
                    Navigator.pop(context);
                    if (extension) showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => page);
                  }),
            ),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                child: Icon(Icons.close, color: extension ? Colors.transparent : Colors.white, size: 25),
                onTap: () {
                  if (!extension) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        decoration:
            BoxDecoration(color: colors.paddygreen, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        width: getWidth(context),
        height: 40);
  }
}
