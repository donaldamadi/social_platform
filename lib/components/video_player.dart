import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  String videoUrl;
  VideoPlayerWidget({required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController controller = VideoPlayerController.network("");
  BetterPlayerController? betterPlayerController;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Stack(
          children: [
            Container(
              height: getHeight(context),
              width: getWidth(context),
              color: Colors.black,
              child: Container(
                height: getHeight(context) * 0.8,
                width: getWidth(context),
                child: controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: 1,
                        child: VideoPlayer(controller),
                      )
                    : Container(child: CircularProgressIndicator(), width: 50, height: 50),
              ),
            ),
            Positioned(
              top: 80,
              left: 15,
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
      ),
    );
  }
}
