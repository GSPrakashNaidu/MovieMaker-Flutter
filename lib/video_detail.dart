import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'globals.dart' as globals;

class VideoDetail extends StatelessWidget {
  final String videoPath;

  // Constructor
  VideoDetail({Key key, @required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = videoPath.split("/").last;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: _buildVideoThumbnailView(videoPath),
    );
  }

  FutureBuilder<Uint8List> _buildVideoThumbnailView(String path) {
    return new FutureBuilder<Uint8List>(
        future: _getVideoThumnail(path), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return _buildInlineVideo(snapshot.data);
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.none:
            default:
              return Image.asset("assets/ic_placeholder_80px.png");
          }
        });
  }

  Future<Uint8List> _getVideoThumnail(String path) async {
    return await globals.cache.get(path.hashCode);
  }

  Widget _buildInlineVideo(Uint8List data) {
    return Center(
      child: new FadeInImage(
        fit: BoxFit.fill,
        placeholder: AssetImage("assets/ic_placeholder_80px.png"),
        image: MemoryImage(data, scale: 1.0),
      ),
    );
  }
}
