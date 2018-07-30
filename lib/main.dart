import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medias_picker/medias_picker.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'cache.dart';

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
  List<dynamic> videosPath = List();
  Cache<Uint8List> cache = MemCache();

  static const MethodChannel methodChannel =
      const MethodChannel('moviemaker.devunion.com/movie_maker_channel');

  String _batteryLevel = 'Battery level: unknown.';

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
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
      body: Column(
        children: <Widget>[
          Flexible(
            child: _buildBatteryLevelSection(),
            flex: 0,
          ),
          Flexible(
            child: _buildContentSection(),
            flex: 1,
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          debugPrint("Bipin - FAB pressed");
          pickVideos().asStream().listen(_setResults);
        },
        tooltip: "Pick a Video",
        child: new Icon(Icons.add),
      ),
    );

    return child;
  }

  void _setResults(List<dynamic> results) {
    setState(() {
      videosPath.addAll(results);
    });
  }

  Future<List<dynamic>> pickVideos() async {
    List<dynamic> paths;
    try {
      if (Platform.isAndroid) {
        if (!await MediasPicker.checkPermission()) {
          if (!await MediasPicker.requestPermission()) {
            return List();
          }
        }
      }
      paths = await MediasPicker.pickVideos(quantity: 10);
      debugPrint("Bipin - selected videos paths: $paths");
    } on PlatformException {
      debugPrint("Bipin - PlatformExcetion while picking videos");
    }

    if (!mounted) return List();

    return paths;
  }

  Widget _buildContentSection() {
    if (videosPath.isNotEmpty) {
      List<Widget> itemWidgets = videosPath
          .map((path) => _buildVideoThumbnailView(path.toString()))
          .toList();
      return new CustomScrollView(
        primary: false,
        slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: new SliverGrid.count(
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              childAspectRatio: 3 / 2,
              crossAxisCount: 2,
              children: itemWidgets,
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Text("No media added yet, Please add few using + sign"),
      );
    }
  }

  Future<Uint8List> _getVideoThumnail(String path) async {
    Uint8List imageBytes;
    try {
      imageBytes = await cache.get(path.hashCode);
      if (imageBytes == null) {
        imageBytes = await methodChannel
            .invokeMethod('getVideoThumbnail', {"videoPath": path});
        cache.put(path.hashCode, imageBytes);
      }
    } on PlatformException {}
    return imageBytes;
  }

  Widget _buildInlineVideo(Uint8List data) {
    return Container(
      color: Colors.blue,
      child: new FadeInImage(
        fit: BoxFit.fill,
        placeholder: AssetImage("assets/ic_placeholder_80px.png"),
        image: MemoryImage(data, scale: 1.0),
      ),
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

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%.';
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Widget _buildBatteryLevelSection() {
    return Container(
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Text(_batteryLevel),
        ),
      ),
    );
  }

  Future<String> _createMovie(List<dynamic> paths) async {
    var videoPaths = List<String>();
    for (var i = 0; i < paths.length; i++) {
      videoPaths.add(paths[i]);
    }
    String moviePath;
    try {
      moviePath = await methodChannel
          .invokeMethod('createMovie', {"videoPaths": paths});
      debugPrint("Bipin - Movie created path: $moviePath");
    } on PlatformException {}

    return moviePath;
  }

  Future<Null> _startMovie(String moviePath) async {
    debugPrint("Bipin - Created Movie path: $moviePath");
    try {
      var started = await methodChannel
          .invokeMethod('startMovie', {"moviePath": moviePath});
      debugPrint("Bipin - is Movie started: $started");
    } on PlatformException {}
  }
}
