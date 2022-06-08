import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/textControl.dart';

customAutocompleteSheet(BuildContext context, List<Map<String, dynamic>> list) {
  showModalBottomSheet<dynamic>(
      useRootNavigator: true,
      elevation: 5,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      context: context,
      builder: (context) {
        return Wrap(
          direction: Axis.vertical,
          // mainAxisSize: MainAxisSize.min,
          children: List.generate(
            list.length > 10 ? 10 : list.length,
            (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 60,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(list[index]['profilepic']),
                  ),
                  title: textControl(
                      /* list[index]['firstname'] + ' ' + list[index]['lastname'] */ "hello",
                      context),
                  subtitle: textControl(list[index]["username"], context),
                ),
              ),
            ),
          ),
        );
      });
}
