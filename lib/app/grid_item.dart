import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:movie_maker/app/globals.dart' as globals;
import 'package:movie_maker/app/video_detail.dart';

class GridItem extends StatefulWidget {
    final String videoPath;

    GridItem(this.videoPath);

    @override
    _GridItemState createState() => new _GridItemState(videoPath);
}

class _GridItemState extends State<GridItem> {
    final String videoPath;

    _GridItemState(this.videoPath);

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return new FutureBuilder<Uint8List>(
                future: _getVideoThumbnail(), // a Future<String> or null
                builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                    debugPrint("Snapshot state: ${snapshot.connectionState}");
                    switch (snapshot.connectionState) {
                        case ConnectionState.done:
                            return _buildInlineVideo(snapshot.data);
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


    Widget _buildInlineVideo(Uint8List data) {
        return GridTile(
            child: InkResponse(
                child: new FadeInImage(
                    fit: BoxFit.fill,
                    placeholder: AssetImage("assets/ic_placeholder_80px.png"),
                    image: MemoryImage(data, scale: 1.0),
                ),
                onTap: () {
                    //TODO: Move to My_Home_Page widget
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                                builder: (context) => VideoDetail(videoPath: videoPath)),
                    );
                },
            ),
        );
    }

    Future<Uint8List> _getVideoThumbnail() async {
        Uint8List imageBytes;
        try {
            imageBytes = await globals.cache.get(videoPath.hashCode);
            if (imageBytes == null) {
                debugPrint( "fetching thumbnail using methodChannel");
                imageBytes = await globals.methodChannel
                        .invokeMethod('getVideoThumbnail', {"videoPath": videoPath});
                globals.cache.put(videoPath.hashCode, imageBytes);
            }
        } on PlatformException {}
        return imageBytes;
    }

}