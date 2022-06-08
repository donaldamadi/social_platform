import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ShimmerWidget extends StatefulWidget {
  final int count;

  ShimmerWidget({this.count = 1});

  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          //physics: BouncingScrollPhysics(),
          itemCount: widget.count,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            color: Colors.white,
                            height: getSize(context, 40),
                            width: getSize(context, 40),
                          ),
                        ),
                        SizedBox(width: getSize(context, 10)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            height: getSize(context, 20),
                            width: getWidth(context) - 110,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                color: colors.white),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Container(
                            height: getSize(context, 20),
                            // width: getWidth(context),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                color: colors.white),
                          ),
                          SizedBox(width: getSize(context, 10)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: double.infinity - 10,
                        height: getSize(context, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: colors.white),
                      ),
                    ),
                    SizedBox(height: getSize(context, 10)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: getWidth(context) - 10,
                        height: getSize(context, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: colors.white),
                      ),
                    ),
                    SizedBox(height: getSize(context, 10)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: getWidth(context) - 10,
                        height: getSize(context, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: colors.white),
                      ),
                    ),
                    SizedBox(height: getSize(context, 20)),
                    divider(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
