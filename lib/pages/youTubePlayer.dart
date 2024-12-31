import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_tracker/helpers/api_service.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String movieId;
  final double? width;
  final double? height;

  const YouTubePlayerWidget({
    super.key,
    required this.movieId,
    this.width,
    this.height,
  });

  @override
  _YouTubePlayerWidgetState createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  YoutubePlayerController? _controller;
  String? videoId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    String? id = await TmdbService.fetchTrailer(widget.movieId);
    print('id $id');
    if (id != null) {
      setState(() {
        videoId = id;
        _controller = YoutubePlayerController(
          initialVideoId: videoId!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            controlsVisibleAtStart: true,
            enableCaption: true,
          ),
        );
      });
    } else {
      print('No trailer found');
      // Handle the case where no trailer is found
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Text('');
    }

    // Get the screen width to determine if it's mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;

    // Set default values for mobile and desktop views
    double width = screenWidth < 600 ? double.infinity : (widget.width ?? 600); // Adjust width for desktop
    double? height = screenWidth < 600 ? null : (widget.height ?? 500); // Adjust height for desktop

    return Container(
      width: width,
      height: height,
      color: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
            child: Text(
              "Trailer",
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            // The player will automatically toggle fullscreen when the user clicks the fullscreen button on the player
          ),
          const SizedBox(height: 10),

          // Optional: You can remove the fullscreen toggle button here
        ],
      ),
    );
  }
}
