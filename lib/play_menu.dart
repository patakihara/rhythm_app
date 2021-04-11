import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rubber/rubber.dart';
import 'plan_page.dart';
import 'providers.dart';
import 'widgets.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'classes.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PlayMenu extends StatefulWidget {
  PlayMenu({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _PlayMenuState createState() => _PlayMenuState();
}

class _PlayMenuState extends State<PlayMenu> with TickerProviderStateMixin {
  AnimationController controller;
  AnimationController showController;

  Animation<double> playPageFade;
  Animation<double> smallPlayCardFade;
  Animation<Alignment> timerAligment;
  Animation<double> sizeAnimation;
  Animation<double> topAnim;
  Animation<double> timerPaddingLeft;
  Animation<double> bigPlayCardHeight;
  Animation<double> timerSize;

  Animation<Color> color;

  final double bigPlayCardMaxHeight = 56.0 * 5;
  bool openQueue = false;

  AnimationController playStateController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    showController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        value: context.read<NowPlaying>().empty ? 0 : 1);

    // showController.addListener(() {
    //   print('value: ' + showController.value.toString());
    // });

    controller.addStatusListener((status) {
      if (controller.isAnimating && openQueue)
        setState(() {
          openQueue = false;
        });
      setState(() {});
    });

    playPageFade = Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        0.15,
        0.85,
        curve: Curves.ease,
      ),
    ));

    smallPlayCardFade =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        0,
        0.15,
        curve: Curves.ease,
      ),
    ));

    timerAligment = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          1,
          curve: Curves.easeOut,
        ),
      ),
    );

    timerPaddingLeft = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          72 / MediaQuery.of(context).size.height,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    bigPlayCardHeight =
        Tween<double>(begin: 0, end: bigPlayCardMaxHeight).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.3,
          1,
          curve: Curves.easeOut,
        ),
      ),
    );

    timerSize = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          1,
          curve: Curves.easeIn,
        ),
      ),
    );

    color = ColorTween(
            begin: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            end: Theme.of(context).colorScheme.surface)
        .animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          1,
          curve: Curves.easeInOut,
        ),
      ),
    );

    playStateController = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) {
        if (!nowPlaying.empty && showController.isDismissed) {
          showController.fling();
        } else if (nowPlaying.empty && showController.isCompleted) {
          showController.fling(velocity: -1);
        }

        if (nowPlaying.playing && playStateController.isDismissed) {
          playStateController.fling();
        } else if (!nowPlaying.playing && playStateController.isCompleted) {
          playStateController.fling(velocity: -1);
        }

        return ExpandableSheet(
          child: widget.child,
          controller: controller,
          showController: showController,
          onDismiss: nowPlaying.clear,
          initialHeight: context.select<MenuProvider, double>(
              (menuProvider) => menuProvider.playCardHeight),
          sheet: Material(
            elevation: 8,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return SizedBox.expand(
                    child: Container(
                        color: color.value,
                        child: Stack(
                          children: [
                            buildPlayPageTop(nowPlaying, context),
                            Stack(
                              children: [
                                buildSmallPlayCard(context),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: controller.value *
                                          (56 +
                                              MediaQuery.of(context)
                                                  .viewPadding
                                                  .top),
                                    ),
                                    buildTimerIndicator(),
                                    SizedBox(
                                      height: bigPlayCardHeight.value,
                                    ),
                                  ],
                                ),
                                if (!nowPlaying.empty)
                                  buildBigPlayCard(nowPlaying, context)
                              ],
                            ),
                          ],
                        )));
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildBigPlayCard(NowPlaying nowPlaying, BuildContext context) {
    return IgnorePointer(
      ignoring: controller.isDismissed,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: playPageFade.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: bigPlayCardHeight.value,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    height: bigPlayCardMaxHeight,
                    child: Card(
                      elevation: 6,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<Progress>(
                            builder: (context, progress, child) =>
                                LinearPercentIndicator(
                              curve: Curves.fastOutSlowIn,
                              animation: !nowPlaying.playing,
                              animateFromLastPercent: true,
                              animationDuration: 300,
                              percent: progress.percent,
                              lineHeight: 2,
                              progressColor: Theme.of(context).accentColor,
                              backgroundColor:
                                  Theme.of(context).accentColor.withAlpha(60),
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Consumer<Progress>(
                                  builder: (context, progress, child) => Text(
                                    progress.time.minutesSeconds(),
                                    style: Theme.of(context).textTheme.caption,
                                  ),
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
                                              child: Text(nowPlaying.plan.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      .apply(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onBackground
                                                              .withAlpha(160))),
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
                                    Consumer<Progress>(
                                      builder: (context, progress, child) =>
                                          IconButton(
                                              splashRadius: 56 / 2,
                                              icon: Icon(Icons.skip_previous),
                                              onPressed: progress.time != 0
                                                  ? nowPlaying.skipPrevious
                                                  : null),
                                    ),
                                    FloatingActionButton(
                                      shape: CircleBorder(),
                                      disabledElevation: 0,
                                      // elevation: 8,
                                      backgroundColor: !nowPlaying.ended
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Theme.of(context).disabledColor,
                                      child: AnimatedIcon(
                                        progress: playStateController,
                                        icon: AnimatedIcons.play_pause,
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
                ),
              ),
              AnimatedContainer(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: context.select<MenuProvider, Duration>(
                    (menuProvider) => menuProvider.pageTransitionDuration),
                height: () {
                  if (openQueue && controller.isCompleted) {
                    return MediaQuery.of(context).size.height -
                        56 -
                        MediaQuery.of(context).viewPadding.top -
                        bigPlayCardMaxHeight;
                  } else
                    return 0.0;
                }(),
                child: Stack(
                  children: [
                    ClipRect(
                      child: AnimatedContainer(
                        color: Theme.of(context).colorScheme.background,
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration:
                            context.read<MenuProvider>().pageTransitionDuration,
                        height: () {
                          if (openQueue) {
                            return MediaQuery.of(context).size.height -
                                56 -
                                MediaQuery.of(context).viewPadding.top -
                                bigPlayCardMaxHeight;
                          } else
                            return 0.0;
                        }(),
                        child: ListView.builder(
                          itemCount: nowPlaying.plan.exerciseNames.length,
                          itemExtent: 72,
                          padding: EdgeInsets.zero,
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
                          },
                        ),
                      ),
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
      ),
    );
  }

  Align buildTimerIndicator() {
    return Align(
      alignment: timerAligment.value,
      child: Padding(
        padding: EdgeInsets.only(
          left: timerPaddingLeft.value,
        ),
        child: TimerIndicator(
          animation: timerSize,
          isSmall: true,
        ),
      ),
    );
  }

  Opacity buildSmallPlayCard(BuildContext context) {
    return Opacity(
      opacity: smallPlayCardFade.value,
      child: IgnorePointer(
        ignoring: !controller.isDismissed,
        child: SizedBox(
          height: context.read<MenuProvider>().playCardHeight,
          child: SingleChildScrollView(
            child: PlayCard(),
          ),
        ),
      ),
    );
  }

  Opacity buildPlayPageTop(NowPlaying nowPlaying, BuildContext context) {
    return Opacity(
      opacity: playPageFade.value < 0.089 ? 0 : playPageFade.value,
      child: nowPlaying.empty
          ? Container()
          : Stack(
              children: [
                Material(
                  elevation: 6,
                  color: Theme.of(context).colorScheme.background,
                ),
                AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 500),
                  color: nowPlaying.repState == RepState.rest
                      ? Theme.of(context).colorScheme.background.withOpacity(.5)
                      : nowPlaying.repState == RepState.up
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.06)
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(.06),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
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
                          controller
                              .fling(velocity: -1)
                              .then((value) => nowPlaying.clear());
                        },
                      ),
                    ],
                    leading: IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                      ),
                      onPressed: () {
                        controller.fling(velocity: -1);
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
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
