
import 'package:flutter/material.dart';

import 'grid_item.dart';

class CustomGrid extends StatefulWidget {
    final List<String> videosPath;

    CustomGrid(this.videosPath);

    @override
    _CustomGridState createState() => new _CustomGridState(videosPath);
}

class _CustomGridState extends State<CustomGrid> {
    final List<String> videosPath;

    _CustomGridState(this.videosPath);

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        if (videosPath.isNotEmpty) {
            List<Widget> itemWidgets = videosPath
                    .map((videoPath) => GridItem(videoPath))
                    .toList();
            return new CustomScrollView(
                primary: false,
                slivers: <Widget>[
                    new SliverPadding(
                        padding: const EdgeInsets.all(5.0),
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
}