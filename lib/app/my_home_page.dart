import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medias_picker/medias_picker.dart';
import 'package:flutter/services.dart';

import 'package:movie_maker/app/globals.dart' as globals;
import 'grid_view.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static List<String> videosPath = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new Scaffold(
      appBar: new AppBar(
        title: new Text('Movie Maker'),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.movie_creation),
            onPressed: () {
              _createMovie(videosPath)
                  .then((moviePath) => _startMovie(moviePath));
            },
          )
        ],
      ),
      body: CustomGrid(videosPath),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          debugPrint("FAB pressed");
          pickVideos().asStream().listen(_setResults);
        },
        tooltip: "Pick a Video",
        child: new Icon(Icons.add),
      ),
    );

    return child;
  }

  void _setResults(List<String> results) {
    setState(() {
      videosPath.addAll(results);
    });
  }

  Future<List<String>> pickVideos() async {
    List<String> paths = List();
    try {
      if (Platform.isAndroid) {
        if (!await MediasPicker.checkPermission()) {
          if (!await MediasPicker.requestPermission()) {
            return List();
          }
        }
      }
      List<dynamic> selectedPaths = await MediasPicker.pickVideos(quantity: 10);
      selectedPaths.map((videoPath) => paths.add(videoPath));

      debugPrint("selected videos paths: $paths");
    } on PlatformException {
      debugPrint("PlatformExcetion while picking videos");
    }

    if (!mounted) return List();

    return paths;
  }

  Future<String> _createMovie(List<dynamic> paths) async {
    String moviePath;
    try {
      moviePath = await globals.methodChannel
          .invokeMethod('createMovie', {"videoPaths": paths});
      debugPrint("Movie created path: $moviePath");
    } on PlatformException {}

    return moviePath;
  }

  Future<Null> _startMovie(String moviePath) async {
    debugPrint("Created Movie path: $moviePath");
    try {
      var started = await globals.methodChannel
          .invokeMethod('startMovie', {"moviePath": moviePath});
      debugPrint("is Movie started: $started");
    } on PlatformException {}
  }
}
