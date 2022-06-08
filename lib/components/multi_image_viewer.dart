import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Widget multiImageViewer(BuildContext context, List<String> images) {
  if (images.length == 0) {
    return Container();
  }
  if (images.length == 1) {
    return GestureDetector(
      onTap: () => openImage(context, 0, images),
      child: Container(
        height: 205,
        width: getWidth(context),
        decoration: BoxDecoration(
          color: colors.paddygreen,
          image: DecorationImage(
              image: NetworkImage(images[0]), fit: BoxFit.cover),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
    );
  } else if (images.length == 2) {
    return Container(
      height: 205,
      width: getWidth(context),
      child: Row(children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 1),
            child: GestureDetector(
              onTap: () => openImage(context, 0, images),
              child: Container(
                height: 205,
                width: getWidth(context) / 2,
                decoration: BoxDecoration(
                    color: colors.paddygreen,
                    image: DecorationImage(
                        image: NetworkImage(images[0]), fit: BoxFit.cover),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5))),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 1),
            child: GestureDetector(
              onTap: () => openImage(context, 1, images),
              child: Container(
                height: 205,
                width: getWidth(context) / 2,
                decoration: BoxDecoration(
                    color: colors.paddygreen,
                    image: DecorationImage(
                        image: NetworkImage(images[1]), fit: BoxFit.cover),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
              ),
            ),
          ),
        ),
      ]),
    );
  } else if (images.length == 3) {
    return Container(
      height: 205,
      width: getWidth(context),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2, bottom: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 0, images),
                    child: Container(
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[0]),
                              fit: BoxFit.cover),
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 1, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[1]),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 0),
            child: GestureDetector(
              onTap: () => openImage(context, 2, images),
              child: Container(
                width: getWidth(context) / 2,
                decoration: BoxDecoration(
                    color: colors.paddygreen,
                    image: DecorationImage(
                        image: NetworkImage(images[2]), fit: BoxFit.cover),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
              ),
            ),
          ),
        ),
      ]),
    );
  } else if (images.length == 4) {
    return Container(
      height: 205,
      width: getWidth(context),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2, bottom: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 0, images),
                    child: Container(
                      // width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[0]),
                              fit: BoxFit.cover),
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 1, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[1]),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, bottom: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 2, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[2]),
                              fit: BoxFit.cover),
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, top: 0),
                  child: GestureDetector(
                    onTap: () => openImage(context, 3, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[3]),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  } else if (images.length > 4) {
    return Container(
      height: 205,
      width: getWidth(context),
      child: Row(children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2, bottom: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 0, images),
                    child: Container(
                        decoration: BoxDecoration(
                            color: colors.paddygreen,
                            image: DecorationImage(
                                image: NetworkImage(images[0]),
                                fit: BoxFit.cover),
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(5))),
                        ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 1, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[1]),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, bottom: 2),
                  child: GestureDetector(
                    onTap: () => openImage(context, 2, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[2]),
                              fit: BoxFit.cover),
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(5))),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, top: 0),
                  child: GestureDetector(
                    onTap: () => openImage(context, 3, images),
                    child: Container(
                      width: getWidth(context) / 2,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: NetworkImage(images[3]),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(5))),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5))),
                        child: Center(
                            child: textControl("+${images.length - 4}", context,
                                size: 30)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  } else {
    return SizedBox();
  }
}
