import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medias_picker/medias_picker.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Movie Maker',
            theme: new ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: new MyHomePage(),
        );
    }
}

class MyHomePage extends StatefulWidget {
    @override
    _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    File _video;
    VideoPlayerController _controller;

//  Future getImage() async {
//    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);
//    setState(() {
//      _video = video;
//    });
//  }
    String _platformVersion = "Unknown";
    List<dynamic> docPaths;

    pickVideos() async {
        try {
            if (Platform.isAndroid) {
                if (!await MediasPicker.checkPermission()) {
                    if (!await MediasPicker.requestPermission()) {
                        return;
                    }
                }
            }
            docPaths = await MediasPicker.pickVideos(quantity: 1);
            debugPrint("Bipin - docPaths: $docPaths");
        } on PlatformException {
            debugPrint("Bipin - PlatformExcetion while picking videos");
        }

        if (!mounted) return;

        setState(() {
            _platformVersion = docPaths.toString();
            debugPrint("Bipin - _platformVersion: $docPaths");
        });
    }

    @override
    void initState() {
        super.initState();
//    _controller = VideoPlayerController
//        .file(File('/storage/emulated/0/DCIM/Camera/VID_20180719_030046.mp4'))
////        .network(
////            'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4')
//          ..addListener(() {
//            //_controller.play();
//            print("add Listener");
//          })
//          ..initialize().then((_) {
//            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//            setState(() {
//              print("set state");
//            });
//          });
    }

    @override
    Widget build(BuildContext context) {
        Widget child = new Scaffold(
            appBar: new AppBar(
                title: new Text('Movie Maker'),
            ),
//      body: new Center(
//        child: getVideoImage(),
//      ),
            floatingActionButton: new FloatingActionButton(
                onPressed: () {
                    pickVideos();
                },
                tooltip: 'Pick a Video',
                child: new Icon(Icons.add),
            ),
        );

        return child;
    }

//    Widget getVideoImage() {
////    if (_video == null) {
////      return new Text('Please select a video by clicking + button');
////    } else {
//        print(" isInit:" + _controller.value.initialized.toString());
//        return _controller.value.initialized
//                ? AspectRatio(
//            aspectRatio: _controller.value.aspectRatio,
//            child: VideoPlayer(_controller),
//        )
//                : Container();
////    }
//    }
}
