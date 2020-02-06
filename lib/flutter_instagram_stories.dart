import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'models/stories.dart';
import 'settings.dart';
import 'models/stories_list_with_pressed.dart';
import 'components//stories_list_skeleton.dart';
import 'models/stories_data.dart';
import 'grouped_stories_view.dart';

export 'grouped_stories_view.dart';

class FlutterInstagramStories extends StatefulWidget {
  /// the name of collection in Firestore, more info here https://github.com/awaik/flutter_instagram_stories
  String collectionDbName;

  ///
  bool showTitleOnIcon = true;
  double fontSizeIcon = 16;

  /// size of icons on the line
  double iconWidth;
  double iconHeight;

  /// how long story lasts
  int imageStoryDuration;

  ProgressPosition progressPosition;
  bool repeat;
  bool inline;

  //double fontSizeStory = 24;
  //bool showTitleInStory = true;

  FlutterInstagramStories({
    @required this.collectionDbName,
    this.showTitleOnIcon,
    this.fontSizeIcon,
    this.iconWidth,
    this.iconHeight,
    this.imageStoryDuration,
    this.progressPosition = ProgressPosition.top,
    this.repeat = true,
    this.inline = false,
    //this.fontSizeStory,
    //this.showTitleInStory,
  });

  @override
  _FlutterInstagramStoriesState createState() =>
      _FlutterInstagramStoriesState();
}

class _FlutterInstagramStoriesState extends State<FlutterInstagramStories> {
  final _storiesData = StoriesData();
  final _firestore = Firestore.instance;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection(widget.collectionDbName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            primary: false,
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(left: 20),
                child: InkWell(
                  child: Container(
                    width: widget.iconWidth,
                    height: widget.iconHeight,
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: StoriesListSkeletonAlone(
                            width: widget.iconWidth,
                            height: widget.iconHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
        final stories = snapshot.data.documents;
        _storiesData.parseStoriesPreview(stories);
        List<Stories> storyWidgets = _storiesData.storyWidgets;
        // the variable below is for passing stories ids to screen Stories
        List<String> storiesIdsList = _storiesData.storiesIdsList;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          primary: false,
          itemCount: storyWidgets == null ? 0 : stories.length,
          itemBuilder: (BuildContext context, int index) {
            Stories story = storyWidgets[index];

            return Padding(
              padding: EdgeInsets.only(left: 20),
              child: InkWell(
                child: Container(
                  width: widget.iconWidth,
                  height: widget.iconHeight,
                  child: Stack(children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: story.previewImage,
                        width: widget.iconWidth,
                        height: widget.iconHeight,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => StoriesListSkeletonAlone(
                          width: widget.iconWidth,
                          height: widget.iconHeight,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Container(
                      width: widget.iconWidth,
                      height: widget.iconHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: (50 - widget.iconHeight) * (-1),
                                left: 8.0,
                                right: 8.0,
                                bottom: 8.0),
                            child: Text(
                              story.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: widget.fontSizeIcon,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupedStoriesView(
                        collectionDbName: widget.collectionDbName,
                        imageStoryDuration: widget.imageStoryDuration,
                        progressPosition: widget.progressPosition,
                        repeat: widget.repeat,
                        inline: widget.inline,
                      ),
                      settings: RouteSettings(
                        arguments: StoriesListWithPressed(
                            pressedStoryId: story.storyId,
                            storiesIdsList: storiesIdsList),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
