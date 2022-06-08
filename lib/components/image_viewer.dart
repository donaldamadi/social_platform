import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  ImageViewer({required this.imageUrl});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
              child: PhotoView(
            // initialScale: 1.0,
            maxScale: 2.0,
            minScale: 0.1,
            imageProvider: NetworkImage(widget.imageUrl),
          )),
          Positioned(
            top: 80,
            left: 15,
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
              child: IconButton(
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
