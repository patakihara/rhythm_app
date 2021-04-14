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

  final double bigPlayCardMaxHeight = 56.0 * 4;
  bool openQueue = false;
  AnimationController queueController;
  Animation<double> queueHeight;
  double maxQueueHeight;
  double minQueueHeight;
  double queueBarHeight = 56.0 + 48;

  double bigPlayCardElevation = 0;
  ScrollController queueScrollController = ScrollController();

  AnimationController playStateController;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    controller.addStatusListener((status) {
      if (controller.isDismissed && queueController.isCompleted)
        queueController.fling(velocity: -0.1);
      setState(() {});
    });

    showController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        value: context.read<NowPlaying>().empty ? 0 : 1);

    playStateController = AnimationController(vsync: this);

    queueController = AnimationController(vsync: this, value: 0);

    queueController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          openQueue = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          openQueue = false;
        });
      }
    });

    queueScrollController.addListener(() {
      if (queueScrollController.offset > 0 && bigPlayCardElevation < 2) {
        setState(() {
          bigPlayCardElevation = 2;
        });
      } else if (queueScrollController.offset == 0 &&
          bigPlayCardElevation == 2) {
        setState(() {
          bigPlayCardElevation =
              Theme.of(context).brightness == Brightness.dark ? 1 : 0;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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

    maxQueueHeight = MediaQuery.of(context).size.height - 48;
    // -
    //     MediaQuery.of(context).viewPadding.top -
    //     56 +
    //     16;
    minQueueHeight = bigPlayCardMaxHeight;

    queueHeight = Tween<double>(begin: minQueueHeight, end: maxQueueHeight)
        .animate(queueController);

    if (Theme.of(context).brightness == Brightness.dark)
      bigPlayCardElevation = 1;
    else
      bigPlayCardElevation = 0;
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
          detectGestures: queueController.isDismissed,
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
                        IgnorePointer(
                            ignoring: (controller.isDismissed ||
                                queueController.isCompleted),
                            child: buildPlayPageTop(nowPlaying, context)),
                        buildSmallPlayCard(context),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: controller.value *
                                  (56 + MediaQuery.of(context).viewPadding.top),
                            ),
                            buildTimerIndicator(),
                            SizedBox(
                              height: bigPlayCardHeight.value,
                            ),
                          ],
                        ),
                        if (!nowPlaying.empty)
                          buildBigPlayCard(nowPlaying, context),
                        if (controller.isCompleted)
                          AnimatedBuilder(
                            animation: queueController,
                            builder: (context, child) => Positioned(
                              top: Tween<double>(
                                      begin: -(queueBarHeight +
                                          MediaQuery.of(context)
                                              .viewPadding
                                              .top),
                                      end: 0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: queueController,
                                      curve: Interval(0.5, 1.0,
                                          curve: Curves.easeOut),
                                    ),
                                  )
                                  .value,
                              child: IgnorePointer(
                                ignoring: !queueController.isCompleted,
                                child: Material(
                                  color: Theme.of(context).colorScheme.surface,
                                  elevation: 4,
                                  child: AnimatedContainer(
                                    curve: Curves.fastOutSlowIn,
                                    duration: Duration(milliseconds: 500),
                                    color: nowPlaying.repState == RepState.rest
                                        ? Theme.of(context).colorScheme.surface
                                        : nowPlaying.repState == RepState.up
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(.06)
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(.06),
                                    alignment: AlignmentDirectional.topCenter,
                                    height: queueBarHeight +
                                        MediaQuery.of(context).viewPadding.top,
                                    width: MediaQuery.of(context).size.width,
                                    child: Opacity(
                                      opacity: Tween<double>(begin: 0, end: 1)
                                          .animate(
                                            CurvedAnimation(
                                              parent: queueController,
                                              curve: Interval(
                                                0.7,
                                                1.0,
                                              ),
                                            ),
                                          )
                                          .value,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppBar(
                                            backwardsCompatibility: false,
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            elevation: 0,
                                            title: Text('Queue'),
                                            leading: IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                queueController.fling(
                                                    velocity: -1);
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            // height: 48,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 56.0 + 16,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        (nowPlaying.exercise !=
                                                                    null
                                                                ? nowPlaying
                                                                    .exercise
                                                                    .name
                                                                : 'No exercise') +
                                                            '  ·  ' +
                                                            (nowPlaying.inSet
                                                                ? nowPlaying
                                                                    .currentRep
                                                                    .pluralString(
                                                                        'rep')
                                                                : nowPlaying
                                                                        .inReady
                                                                    ? 'Ready'
                                                                    : nowPlaying
                                                                            .inRest
                                                                        ? 'Rest'
                                                                        : 'Done') +
                                                            (!nowPlaying.inEnd
                                                                ? ', ' +
                                                                    nowPlaying
                                                                        .currentSet
                                                                        .cardinal() +
                                                                    ' set'
                                                                : ', ' +
                                                                    nowPlaying
                                                                        .currentSet
                                                                        .pluralString(
                                                                            'set')),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .apply(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (nowPlaying.plan !=
                                                              null &&
                                                          nowPlaying
                                                                  .plan.name !=
                                                              '')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4.0),
                                                          child: Text(
                                                            nowPlaying.plan !=
                                                                    null
                                                                ? nowPlaying
                                                                    .plan.name
                                                                : 'No plan',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1
                                                                .apply(
                                                                    fontWeightDelta:
                                                                        -1,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onBackground
                                                                        .withOpacity(
                                                                            .6)),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildBigPlayCard(NowPlaying nowPlaying, BuildContext context) {
    print('Timer duration is: ' + nowPlaying.duration.toString());

    return IgnorePointer(
      ignoring: controller.isDismissed,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: playPageFade.value,
          child: AnimatedBuilder(
            animation: queueController,
            builder: (context, child) => SizedBox(
              height: queueHeight.value * controller.value,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ExpandableBox(
                  maxHeight: maxQueueHeight,
                  minHeight: minQueueHeight,
                  controller: queueController,
                  // curve: Curves.fastLinearToSlowEaseIn,
                  // duration: context.select<MenuProvider, Duration>(
                  //     (menuProvider) => menuProvider.pageTransitionDuration),
                  height: queueHeight,
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: nowPlaying.plan.exerciseNames.length,
                        controller: queueScrollController,
                        // itemExtent: 72,
                        padding: EdgeInsets.only(top: bigPlayCardMaxHeight),
                        itemBuilder: (_, int i) {
                          bool currentlyPlaying() =>
                              nowPlaying.exerciseIndex == i;
                          bool willPlayLater() => i > nowPlaying.exerciseIndex;
                          bool hasPlayedBefore() =>
                              i < nowPlaying.exerciseIndex;
                          return ExerciseTileSmall(
                            selected: currentlyPlaying(),
                            exercise: nowPlaying.plan.exercises[i],
                            leading: SizedBox(
                              width: 72.0 - 32.0,
                              child: Center(
                                child: Text(
                                  (i + 1).toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(.6),
                                  ),
                                ),
                              ),
                            ),
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
                      Material(
                        child: SizedBox(
                          height: 12,
                        ),
                        elevation: 24,
                      ),
                      SizedBox(
                        height: bigPlayCardMaxHeight,
                        child: Card(
                          elevation: bigPlayCardElevation,
                          margin: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: Tween<double>(begin: 1, end: 0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: queueController,
                                            curve: Interval(
                                              0.3,
                                              0.8,
                                            ),
                                          ),
                                        )
                                        .value,
                                    child: Padding(
                                      // Exercise and plan name
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 8),
                                      child: Column(
                                        children: [
                                          Text(
                                            nowPlaying.exercise.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground
                                                      .withAlpha(255),
                                                ),
                                          ),
                                          nowPlaying.plan.name != ''
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0,
                                                          top: 4.0),
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
                                                              .withAlpha(160),
                                                        ),
                                                  ),
                                                )
                                              : SizedBox(height: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    // Progress indicator and time
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 36.0, vertical: 8),
                                    child: Consumer<Progress>(
                                      builder: (context, progress, child) =>
                                          Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          LinearPercentIndicator(
                                            curve: Curves.fastOutSlowIn,
                                            animation: !nowPlaying.playing,
                                            animateFromLastPercent: true,
                                            animationDuration: 300,
                                            percent: progress.percent,
                                            lineHeight: 2,
                                            progressColor:
                                                Theme.of(context).accentColor,
                                            backgroundColor: Theme.of(context)
                                                .accentColor
                                                .withAlpha(60),
                                            padding: EdgeInsets.all(0),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Consumer<Progress>(
                                                  builder: (context, progress,
                                                          child) =>
                                                      Text(
                                                    progress.time
                                                        .minutesSeconds(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption,
                                                  ),
                                                ),
                                                Text(
                                                  nowPlaying.duration
                                                      .minutesSeconds(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    // Play buttons
                                    padding: const EdgeInsets.only(
                                        left: 32, right: 32, bottom: 16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                            padding: EdgeInsets.zero,
                                            splashRadius: 56 / 2,
                                            icon: Icon(MdiIcons.skipBackward),
                                            onPressed: nowPlaying.isFirst
                                                ? null
                                                : nowPlaying.skipBackward),
                                        Consumer<Progress>(
                                          builder: (context, progress, child) =>
                                              IconButton(
                                                  padding: EdgeInsets.zero,
                                                  splashRadius: 56 / 2,
                                                  icon:
                                                      Icon(Icons.skip_previous),
                                                  onPressed: progress.time != 0
                                                      ? nowPlaying.skipPrevious
                                                      : null),
                                        ),
                                        FloatingActionButton(
                                          shape: CircleBorder(),
                                          disabledElevation: 0,
                                          elevation: 0,
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
                                            padding: EdgeInsets.zero,
                                            splashRadius: 56 / 2,
                                            icon: Icon(Icons.skip_next),
                                            onPressed: !nowPlaying.ended
                                                ? nowPlaying.skipNext
                                                : null),
                                        IconButton(
                                            padding: EdgeInsets.zero,
                                            splashRadius: 56 / 2,
                                            icon: Icon(MdiIcons.skipForward),
                                            onPressed: nowPlaying.isLast
                                                ? null
                                                : nowPlaying.skipForward),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // AnimatedContainer(
                              //   curve: Curves.fastOutSlowIn,
                              //   duration: Duration(milliseconds: 500),
                              //   color: nowPlaying.repState == RepState.rest
                              //       ? Theme.of(context)
                              //           .colorScheme
                              //           .background
                              //           .withOpacity(.5)
                              //       : nowPlaying.repState == RepState.up
                              //           ? Theme.of(context)
                              //               .colorScheme
                              //               .primary
                              //               .withOpacity(.06)
                              //           : Theme.of(context)
                              //               .colorScheme
                              //               .secondary
                              //               .withOpacity(.06),
                              //   child: ListTile(
                              //     trailing: Transform.rotate(
                              //         angle: 3.1416 * queueController.value,
                              //         child: Icon(Icons.keyboard_arrow_up)),
                              //     leading: Icon(Icons.playlist_play),
                              //     dense: false,
                              //     onTap: () {
                              //       if (!openQueue)
                              //         queueController.fling(velocity: 2);
                              //       else
                              //         queueController.fling(velocity: -2);
                              //     },
                              //     title: Text(
                              //       nowPlaying.exerciseIndex <
                              //               nowPlaying
                              //                       .plan.exerciseNames.length -
                              //                   1
                              //           ? 'Up next: ' +
                              //               nowPlaying.plan.exerciseNames[
                              //                   nowPlaying.exerciseIndex + 1]
                              //           : 'Last exercise',
                              //       style: Theme.of(context)
                              //           .textTheme
                              //           .caption
                              //           .apply(
                              //               color: Theme.of(context)
                              //                   .iconTheme
                              //                   .color),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                          controller.fling(velocity: -1);
                          showController
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
