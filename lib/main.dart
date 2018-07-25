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
  List<dynamic> videosPath = List();

//  static const platform = const MethodChannel('samples.flutter.io/battery');


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new Scaffold(
      appBar: new AppBar(
        title: new Text('Movie Maker'),
      ),
      body: _buildContentSection(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          debugPrint("Bipin - FAB pressed");
          pickVideos().asStream().listen(_setResults);
        },
        tooltip: 'Pick a Video',
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
      List<Widget> itemWidgets =
          videosPath.map((path) => _buildItemWidget(path.toString())).toList();
      return new CustomScrollView(
        primary: false,
        slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: new SliverGrid.count(
              crossAxisSpacing: 10.0,
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

  Widget _buildItemWidget(String imagePath) {
    return Stack(
      children: <Widget>[
        new FadeInImage(
          image: new FileImage(File(imagePath)),
          fit: BoxFit.fill,
          width: 100.0,
          height: 150.0,
          placeholder: AssetImage("assets/ic_placeholder_80px.png"),
        ),
        Align(
          child: new Text(
            imagePath,
          ),
          alignment: AlignmentDirectional.bottomStart,
        )
      ],
    );
  }
}
