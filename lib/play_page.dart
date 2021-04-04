import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart' as provider;
import 'classes.dart';
import 'widgets.dart';
import 'providers.dart';
import 'dart:async';

class PlayPage extends StatefulWidget {
  final BuildContext context;

  const PlayPage({Key key, this.context}) : super(key: key);

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage>
    with SingleTickerProviderStateMixin {
  AnimationController ticker;

  bool openQueue = false;

  var playCardHeight = 56.0 * 5;

  @override
  void initState() {
    ticker = AnimationController(
        vsync: this, value: 0, duration: Duration(minutes: 1));
    ticker.addListener(() {
      provider.Provider.of<NowPlaying>(context, listen: false).updateTime();
    });
    ticker.repeat();
    super.initState();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) => GestureDetector(
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity > 0) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            Material(
              elevation: 6,
              color: Theme.of(context).colorScheme.background,
            ),
            AnimatedContainer(
              curve: Curves.fastOutSlowIn,
              duration: Duration(milliseconds: 500),
              color: nowPlaying.repState == RepState.rest
                  ? Theme.of(context).colorScheme.background
                  : nowPlaying.repState == RepState.up
                      ? Theme.of(context).colorScheme.primary.withOpacity(.08)
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(.08),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              // appBar: PreferredSize(
              //     preferredSize: Size(112, 56),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Container(
              //           height: MediaQuery.of(context).viewPadding.top,
              //           color: Theme.of(context).brightness == Brightness.dark
              //               ? Colors.black
              //               : Colors.white,
              //           width: 112,
              //         ),
              //         Material(
              //           elevation: 4,
              //           clipBehavior: Clip.hardEdge,
              //           shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.only(
              //                   bottomRight: Radius.circular(28))),
              //           child: Container(
              //             height: 56,
              //             width: 112,
              //             // color: Colors.red,
              //             decoration: BoxDecoration(
              //                 color: Theme.of(context).brightness ==
              //                         Brightness.dark
              //                     ? Colors.black
              //                     : Colors.white,
              //                 borderRadius: BorderRadius.only(
              //                     bottomRight: Radius.circular(28))),
              //             child: Row(children: [
              //               IconButton(
              //                 padding: EdgeInsets.only(
              //                     left: 16, right: 12, top: 16, bottom: 16),
              //                 icon: Icon(
              //                   Icons.keyboard_arrow_down,
              //                 ),
              //                 onPressed: () {
              //                   Navigator.pop(context);
              //                 },
              //               ),
              //               IconButton(
              //                   padding: EdgeInsets.only(left: 12, right: 16),
              //                   icon: Icon(
              //                     Icons.stop,
              //                   ),
              //                   onPressed: () {
              //                     Navigator.pop(context);
              //                     Timer(
              //                         provider.Provider.of<MenuProvider>(
              //                                 context,
              //                                 listen: false)
              //                             .pageTransitionDuration,
              //                         () => provider.Provider.of<NowPlaying>(
              //                                 context,
              //                                 listen: false)
              //                             .clear());
              //                   })
              //             ]),
              //           ),
              //         ),
              //       ],
              //     )),
              appBar: AppBar(
                // title: Text('Timer'),
                backgroundColor: Colors.transparent,
                iconTheme: Theme.of(context).iconTheme,
                textTheme: Theme.of(context)
                    .textTheme
                    .apply(bodyColor: Theme.of(context).iconTheme.color),
                elevation: 0,
                actions: [
                  IconButton(
                      padding: EdgeInsets.all(16),
                      icon: Icon(
                        Icons.stop,
                      ),
                      onPressed: () {
                        Timer(
                          provider.Provider.of<MenuProvider>(
                            context,
                            listen: false,
                          ).pageTransitionDuration,
                          () => provider.Provider.of<NowPlaying>(
                            context,
                            listen: false,
                          ).clear(),
                        );
                        Navigator.pop(context);
                      }),
                ],
                leading: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              extendBodyBehindAppBar: false,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // SizedBox(height: 56 + MediaQuery.of(context).viewInsets.top),
                    Expanded(
                        child: Center(
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: HeroTimerIndicator(
                          isSmall: false,
                        ),
                      ),
                    )),
                    Container(
                      height: playCardHeight,
                      child: Card(
                        elevation: 6,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LinearPercentIndicator(
                              curve: Curves.fastOutSlowIn,
                              animation: !nowPlaying.playing,
                              animateFromLastPercent: true,
                              animationDuration: 300,
                              percent: nowPlaying.percent,
                              lineHeight: 2,
                              progressColor: Theme.of(context).accentColor,
                              backgroundColor:
                                  Theme.of(context).accentColor.withAlpha(60),
                              padding: EdgeInsets.all(0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 8.0, right: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    nowPlaying.time.minutesSeconds(),
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  Text(
                                    nowPlaying.duration.minutesSeconds(),
                                    style: Theme.of(context).textTheme.caption,
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      children: [
                                        Text(nowPlaying.exercise.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                .apply(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground
                                                        .withAlpha(255))),
                                        nowPlaying.plan.name != ''
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    nowPlaying.plan.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        .apply(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground
                                                                .withAlpha(
                                                                    160))),
                                              )
                                            : SizedBox(height: 0),
                                      ],
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                          splashRadius: 56 / 2,
                                          icon: Icon(MdiIcons.skipBackward),
                                          onPressed: nowPlaying.isFirst
                                              ? null
                                              : nowPlaying.skipBackward),
                                      IconButton(
                                          splashRadius: 56 / 2,
                                          icon: Icon(Icons.skip_previous),
                                          onPressed: nowPlaying.time != 0
                                              ? nowPlaying.skipPrevious
                                              : null),
                                      FloatingActionButton(
                                        shape: CircleBorder(),
                                        disabledElevation: 0,
                                        // elevation: 8,
                                        backgroundColor: !nowPlaying.ended
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context).disabledColor,
                                        child: Icon(
                                          !nowPlaying.playing
                                              ? Icons.play_arrow
                                              : Icons.pause,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                        ),
                                        onPressed: !nowPlaying.ended
                                            ? nowPlaying.togglePlay
                                            : null,
                                      ),
                                      IconButton(
                                          splashRadius: 56 / 2,
                                          icon: Icon(Icons.skip_next),
                                          onPressed: !nowPlaying.ended
                                              ? nowPlaying.skipNext
                                              : null),
                                      IconButton(
                                          splashRadius: 56 / 2,
                                          icon: Icon(MdiIcons.skipForward),
                                          onPressed: nowPlaying.isLast
                                              ? null
                                              : nowPlaying.skipForward),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: AnimatedContainer(
                                    curve: Curves.fastOutSlowIn,
                                    duration: Duration(milliseconds: 500),
                                    color: nowPlaying.repState == RepState.rest
                                        ? Theme.of(context)
                                            .colorScheme
                                            .background
                                            .withOpacity(.5)
                                        : nowPlaying.repState == RepState.up
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(.06)
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(.06),
                                    child: ListTile(
                                      trailing: Icon(openQueue
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_up),
                                      leading: Icon(Icons.playlist_play),
                                      dense: false,
                                      onTap: () {
                                        setState(() => openQueue = !openQueue);
                                      },
                                      title: Text(
                                          nowPlaying.exerciseIndex <
                                                  nowPlaying.plan.exerciseNames
                                                          .length -
                                                      1
                                              ? 'Up next: ' +
                                                  nowPlaying.plan.exerciseNames[
                                                      nowPlaying.exerciseIndex +
                                                          1]
                                              : 'Last exercise',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .apply(
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Stack(
                children: [
                  ClipRect(
                    child: AnimatedContainer(
                        color: Theme.of(context).colorScheme.background,
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: provider.Provider.of<MenuProvider>(context)
                            .pageTransitionDuration,
                        height: () {
                          if (openQueue) {
                            return MediaQuery.of(context).size.height -
                                56 -
                                MediaQuery.of(context).viewPadding.top -
                                playCardHeight;
                          } else
                            return 0.0;
                        }(),
                        child: ListView.builder(
                            itemCount: nowPlaying.plan.exerciseNames.length,
                            itemExtent: 72,
                            itemBuilder: (_, int i) {
                              bool currentlyPlaying() =>
                                  nowPlaying.exerciseIndex == i;
                              bool willPlayLater() =>
                                  i > nowPlaying.exerciseIndex;
                              bool hasPlayedBefore() =>
                                  i < nowPlaying.exerciseIndex;
                              return ExerciseTile(
                                selected: currentlyPlaying(),
                                exercise: nowPlaying.plan.exercises[i],
                                onTap: () {
                                  if (!currentlyPlaying()) {
                                    if (willPlayLater())
                                      while (!currentlyPlaying())
                                        nowPlaying.skipForward();
                                    else if (hasPlayedBefore())
                                      while (!currentlyPlaying())
                                        nowPlaying.skipBackward();
                                    nowPlaying.play();
                                  }
                                },
                              );
                            })),
                  ),
                  Material(
                    elevation: 2,
                    child: Divider(
                        height: 0.0001,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
