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
  Future<List> videosPath;

  Future<List> pickVideos() async {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: videosPath,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(
              child: Text("No media added yet, Please add few using + sign"),
            );
          case ConnectionState.waiting:
            return Center(
              child: Text("loading..."),
            );
          default:
            if (snapshot.hasError)
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            else
              return getVideoImageList(context, snapshot);
        }
      },
    );

    Widget child = new Scaffold(
      appBar: new AppBar(
        title: new Text('Movie Maker'),
      ),
      body: futureBuilder,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          debugPrint("Bipin - FAB pressed");
          videosPath = pickVideos();
          debugPrint("Bipin - videosPath: $videosPath");
        },
        tooltip: 'Pick a Video',
        child: new Icon(Icons.add),
      ),
    );

    return child;
  }

  Widget getVideoImageList(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> values = snapshot.data;
    debugPrint("Bipin - values: $values");
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(values[index].toString()),
            ),
            new Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }
}
