import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medias_picker/medias_picker.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'globals.dart' as globals;
import 'video_detail.dart';
//import 'package:progress_hud/progress_hud.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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
  static List<dynamic> videosPath = List();

  static const MethodChannel methodChannel =
      const MethodChannel('moviemaker.devunion.com/movie_maker_channel');

  String _batteryLevel = 'Battery level: unknown.';
//  ProgressHUD _progressHUD;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
//    _getBatteryLevel();

//    _progressHUD = new ProgressHUD(
//      backgroundColor: Colors.black12,
//      color: Colors.white,
//      containerColor: Colors.blue,
//      borderRadius: 5.0,
//      text: 'Loading...',
//      loading: false,
//    );
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
              _createMovieSync(videosPath);
            },
          )
        ],
      ),
      body: ModalProgressHUD(child: _buildContentSection(), inAsyncCall: _loading),
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

  void toggleProgressHUD() {
//    setState(() {
//      if (_loading) {
//        _progressHUD.state.dismiss();
//      } else {
//        _progressHUD.state.show();
//      }
//      _loading = !_loading;
//    });
    setState(() {
      _loading = !_loading;
    });
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
      imageBytes = await globals.cache.get(path.hashCode);
      if (imageBytes == null) {
        debugPrint("Bipin - fetching thumbnail using methodChannel");
        imageBytes = await methodChannel
            .invokeMethod('getVideoThumbnail', {"videoPath": path});
        globals.cache.put(path.hashCode, imageBytes);
      }
    } on PlatformException {}
    return imageBytes;
  }

  Widget _buildInlineVideo(String videoPath, Uint8List data) {
    return GridTile(
      child: InkResponse(
        child: new FadeInImage(
          fit: BoxFit.fill,
          placeholder: AssetImage("assets/ic_placeholder_80px.png"),
          image: MemoryImage(data, scale: 1.0),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoDetail(videoPath: videoPath)),
          );
        },
      ),
    );
  }

  FutureBuilder<Uint8List> _buildVideoThumbnailView(String path) {
    return new FutureBuilder<Uint8List>(
        future: _getVideoThumnail(path), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          debugPrint("Bipin - Snapshot state: ${snapshot.connectionState}");
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return _buildInlineVideo(path, snapshot.data);
            case ConnectionState.waiting:
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
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

  void _createMovieSync(List<dynamic> paths) {
    toggleProgressHUD();
    _createMovie(videosPath).then((moviePath) {
      debugPrint("Bipin - _createMovieSync Movie created path: $moviePath");
      _startMovie(moviePath).then((_) {
        debugPrint("Bipin - start movie then");
      }).catchError((error) {
        debugPrint("Bipin - start movie error:");
      }).whenComplete(() {
        debugPrint("Bipin - start movie completed.");
        toggleProgressHUD();
      });
    }).catchError((error) {
      debugPrint("Bipin - Create movie error: ${error.toString()}");
    }).whenComplete(() {
      debugPrint("Bipin - Create movie completed.");
    });
  }

  Future<String> _createMovie(List<dynamic> paths) {
    return Future<String>(() {
      debugPrint("Bipin - Create movie future going to sleep");
      sleep(Duration(seconds: 10));
      debugPrint("Bipin - Create movie future wake up");
      return "FilePath goes here";
    });
//    return methodChannel.invokeMethod('createMovie', {"videoPaths": paths});
  }

  Future<Null> _startMovie(String moviePath) async {
    return Future<Null>(() {
      debugPrint("Bipin - Start movie future going to sleep");
      sleep(Duration(seconds: 10));
      debugPrint("Bipin - Start movie future wake up");
    });
//    debugPrint("Bipin - Created Movie path: $moviePath");
//    return methodChannel.invokeMethod('startMovie', {"moviePath": moviePath});
  }
}
