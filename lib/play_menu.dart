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
  // Animation<double> bigPlayCardHeight;
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

    // bigPlayCardHeight =
    //     Tween<double>(begin: 0, end: bigPlayCardMaxHeight).animate(
    //   CurvedAnimation(
    //     parent: controller,
    //     curve: Interval(
    //       0.3,
    //       1,
    //       curve: Curves.easeOut,
    //     ),
    //   ),
    // );

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

    maxQueueHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        queueBarHeight;
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
                        if (controller.isCompleted) buildQueueTop(nowPlaying),
                        if (!nowPlaying.empty)
                          buildBigPlayCard(nowPlaying, context),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: queueController,
                                builder: (context, child) => SizedBox(
                                  height: controller.value *
                                      Tween<double>(
                                              begin: 56 +
                                                  MediaQuery.of(context)
                                                      .viewPadding
                                                      .top,
                                              end: MediaQuery.of(context)
                                                  .viewPadding
                                                  .top)
                                          .animate(
                                            CurvedAnimation(
                                              parent: queueController,
                                              curve: Interval(
                                                0,
                                                0.7,
                                              ),
                                            ),
                                          )
                                          .value,
                                ),
                              ),
                            ),
                            buildTimerIndicator(),
                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: queueController,
                                builder: (context, child) => SizedBox(
                                  height: controller.value *
                                      Tween<double>(
                                              begin: minQueueHeight,
                                              end: maxQueueHeight)
                                          .animate(
                                            CurvedAnimation(
                                              parent: queueController,
                                              curve: Interval(
                                                0,
                                                0.7,
                                              ),
                                            ),
                                          )
                                          .value,
                                ),
                              ),
                            ),
                          ],
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

  AnimatedBuilder buildQueueTop(NowPlaying nowPlaying) {
    return AnimatedBuilder(
      animation: queueController,
      builder: (context, child) => Positioned(
        top: 0,
        // Tween<double>(
        //         begin: -(queueBarHeight +
        //             MediaQuery.of(context)
        //                 .viewPadding
        //                 .top),
        //         end: 0)
        //     .animate(
        //       CurvedAnimation(
        //         parent: queueController,
        //         curve: Interval(0.5, 1.0,
        //             curve: Curves.easeOut),
        //       ),
        //     )
        //     .value,
        child: IgnorePointer(
          ignoring: !queueController.isCompleted,
          child: Opacity(
            opacity: Tween<double>(begin: 0, end: 1)
                .animate(
                  CurvedAnimation(
                    parent: queueController,
                    curve: Interval(
                      0.75,
                      0.85,
                    ),
                  ),
                )
                .value,
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              // shadowColor: Colors.black.withOpacity(
              //   Tween<double>(begin: 1, end: 0)
              //       .animate(
              //         CurvedAnimation(
              //           parent: queueController,
              //           curve: Interval(
              //             0.95,
              //             1.0,
              //           ),
              //         ),
              //       )
              //       .value,
              // ),
              child: AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Color.alphaBlend(
                        getOverlayColor(bigPlayCardElevation),
                        Color.alphaBlend(
                          nowPlaying.repState == RepState.rest
                              ? Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(.06)
                              : nowPlaying.repState == RepState.up
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.06)
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(.06),
                          Theme.of(context).colorScheme.surface,
                        ),
                      ),
                alignment: AlignmentDirectional.topCenter,
                height: queueBarHeight + MediaQuery.of(context).viewPadding.top,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      backwardsCompatibility: false,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      elevation: 0,
                      title: Text('Queue'),
                      leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          queueController.fling(velocity: -1);
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (nowPlaying.exercise != null
                                          ? nowPlaying.exercise.name
                                          : 'No exercise') +
                                      '  ·  ' +
                                      (nowPlaying.inSet
                                          ? nowPlaying.currentRep
                                              .pluralString('rep')
                                          : nowPlaying.inReady
                                              ? 'Ready'
                                              : nowPlaying.inRest
                                                  ? 'Rest'
                                                  : 'Done') +
                                      (!nowPlaying.inEnd
                                          ? ', ' +
                                              nowPlaying.currentSet.cardinal() +
                                              ' set'
                                          : ', ' +
                                              nowPlaying.currentSet
                                                  .pluralString('set')),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (nowPlaying.plan != null &&
                                    nowPlaying.plan.name != '')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      nowPlaying.plan != null
                                          ? nowPlaying.plan.name
                                          : 'No plan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .apply(
                                              fontWeightDelta: -1,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(.6)),
                                      overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget buildBigPlayCard(NowPlaying nowPlaying, BuildContext context) {
    print('Timer duration is: ' + nowPlaying.duration.toString());

    final titleMaxHeight = 88.0;

    final playCardHeight = Tween<double>(
            begin: bigPlayCardMaxHeight,
            end: bigPlayCardMaxHeight - titleMaxHeight)
        .animate(
      CurvedAnimation(
        parent: queueController,
        curve: Interval(
          0.2,
          .4,
        ),
      ),
    );

    final titleHeight = Tween<double>(begin: titleMaxHeight, end: 0).animate(
      CurvedAnimation(
        parent: queueController,
        curve: Interval(
          0.2,
          .4,
        ),
      ),
    );

    final titleOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: queueController,
        curve: Interval(
          0,
          0.2,
        ),
      ),
    );

    final dividerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: queueController,
        curve: Interval(
          0.95,
          1.0,
        ),
      ),
    );

    final cornerRadius = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: queueController,
        curve: Interval(
          0.95,
          1.0,
        ),
      ),
    );

    final shadowOpacity = Tween<double>(begin: 0.07, end: 0).animate(
      CurvedAnimation(
        parent: queueController,
        curve: Interval(
          0.0,
          0.99,
        ),
      ),
    );

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
                clipBehavior: Clip.none,
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
                        padding: EdgeInsets.only(
                          top: playCardHeight.value,
                        ),
                        itemBuilder: (_, int i) {
                          bool currentlyPlaying() =>
                              nowPlaying.exerciseIndex == i;
                          bool willPlayLater() => i > nowPlaying.exerciseIndex;
                          bool hasPlayedBefore() =>
                              i < nowPlaying.exerciseIndex;
                          return AnimatedContainer(
                            curve: Curves.fastOutSlowIn,
                            duration: Duration(milliseconds: 500),
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.white
                                : Color.alphaBlend(
                                    getOverlayColor(bigPlayCardElevation),
                                    Color.alphaBlend(
                                      nowPlaying.repState == RepState.rest
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                              .withOpacity(.06)
                                          : nowPlaying.repState == RepState.up
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(.06)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(.06),
                                      Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                            child: ExerciseTileSmall(
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
                            ),
                          );
                        },
                      ),
                      // Material(
                      //   child: SizedBox(
                      //     height: 12,
                      //   ),
                      //   elevation: 24,
                      // ),
                      Container(
                        // margin: EdgeInsets.only(
                        //     left: 30, top: 100, right: 30, bottom: 50),
                        // height: double.infinity,
                        // width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(cornerRadius.value),
                            topRight: Radius.circular(cornerRadius.value),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(shadowOpacity.value),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: playCardHeight.value - 12,
                        child: Material(
                          elevation: bigPlayCardElevation,
                          child: SizedBox(
                            height: 12,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: playCardHeight.value,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: Theme.of(context).backgroundColor,
                      //       borderRadius: BorderRadius.only(
                      //         topLeft: Radius.circular(cornerRadius.value),
                      //         topRight: Radius.circular(cornerRadius.value),
                      //       ),
                      //     ),
                      //     clipBehavior: Clip.antiAliasWithSaveLayer,
                      //     child:
                      //         buildColorShiftingContainer(nowPlaying, context),
                      //   ),
                      // ),
                      SizedBox(
                        height: playCardHeight.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(cornerRadius.value),
                              topRight: Radius.circular(cornerRadius.value),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: AnimatedContainer(
                            curve: Curves.fastOutSlowIn,
                            duration: Duration(milliseconds: 500),
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.white
                                : Color.alphaBlend(
                                    getOverlayColor(bigPlayCardElevation),
                                    Color.alphaBlend(
                                      nowPlaying.repState == RepState.rest
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                              .withOpacity(.06)
                                          : nowPlaying.repState == RepState.up
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(.06)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(.06),
                                      Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Opacity(
                                  opacity: dividerOpacity.value,
                                  child: Divider(height: 0),
                                ),
                                SizedBox(
                                  height: titleHeight.value,
                                  width: MediaQuery.of(context).size.width,
                                  child: Opacity(
                                    opacity: titleOpacity.value,
                                    child: FittedBox(
                                      fit: BoxFit.none,
                                      alignment: Alignment.topCenter,
                                      clipBehavior: Clip.antiAlias,
                                      child: SizedBox(
                                        height: titleMaxHeight,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Container(
                                                width: 36,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              // Exercise and plan name
                                              padding: const EdgeInsets.only(
                                                  top: 12, bottom: 8),
                                              child: SizedBox(
                                                height: titleMaxHeight - 32,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      nowPlaying.exercise.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5
                                                          .apply(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground
                                                                .withAlpha(255),
                                                          ),
                                                    ),
                                                    if (nowPlaying.plan.name !=
                                                        '')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 4.0,
                                                        ),
                                                        child: Text(
                                                          nowPlaying.plan.name,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .subtitle2
                                                                  .apply(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onBackground
                                                                        .withAlpha(
                                                                            160),
                                                                  ),
                                                        ),
                                                      ),
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
                                Padding(
                                  // Progress indicator and time
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36.0 + 12, vertical: 8),
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
                                                MainAxisAlignment.spaceBetween,
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
                                      left: 36, right: 36, bottom: 16),
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
                                                icon: Icon(Icons.skip_previous),
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
                          ),
                        ),
                      ),
                      // Container(
                      //   // margin: EdgeInsets.only(
                      //   //     left: 30, top: 100, right: 30, bottom: 50),
                      //   // height: double.infinity,
                      //   // width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.only(
                      //         topLeft: Radius.circular(10),
                      //         topRight: Radius.circular(10),
                      //         bottomLeft: Radius.circular(10),
                      //         bottomRight: Radius.circular(10)),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.grey.withOpacity(0.5),
                      //         spreadRadius: 5,
                      //         blurRadius: 7,
                      //         offset:
                      //             Offset(0, 3), // changes position of shadow
                      //       ),
                      //     ],
                      //   ),
                      // ),
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

  Widget buildTimerIndicator() {
    return AnimatedBuilder(
      animation: queueController,
      builder: (context, child) => Align(
        alignment: !controller.isCompleted
            ? timerAligment.value
            : AlignmentTween(
                    begin: Alignment.center, end: Alignment.centerRight)
                .animate(
                  CurvedAnimation(
                    parent: queueController,
                    curve: Interval(
                      0,
                      0.6,
                    ),
                  ),
                )
                .value,
        child: Padding(
          padding: EdgeInsets.only(
            left: timerPaddingLeft.value,
            right: Tween<double>(begin: 0, end: 32)
                .animate(
                  CurvedAnimation(
                    parent: queueController,
                    curve: Interval(
                      0,
                      0.6,
                    ),
                  ),
                )
                .value,
          ),
          child: child,
        ),
      ),
      child: TimerIndicator(
        animation: !controller.isCompleted
            ? timerSize
            : Tween<double>(begin: 1, end: 0.1).animate(
                CurvedAnimation(
                  parent: queueController,
                  curve: Interval(
                    0,
                    0.7,
                  ),
                ),
              ),
        isSmall: true,
      ),
    );
  }

  Widget buildSmallPlayCard(BuildContext context) {
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

  Widget buildPlayPageTop(NowPlaying nowPlaying, BuildContext context) {
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
                buildColorShiftingContainer(nowPlaying, context),
                AnimatedBuilder(
                  animation: queueController,
                  builder: (context, child) => Opacity(
                    opacity: Tween<double>(begin: 1, end: 0)
                        .animate(
                          CurvedAnimation(
                            parent: queueController,
                            curve: Interval(
                              0,
                              0.5,
                            ),
                          ),
                        )
                        .value,
                    child: child,
                  ),
                  child: Scaffold(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildColorShiftingContainer(
      NowPlaying nowPlaying, BuildContext context,
      {Widget child,
      AlignmentGeometry alignment,
      double height,
      double width,
      Decoration decoration}) {
    return AnimatedContainer(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: 500),
      color: nowPlaying.repState == RepState.rest
          ? Theme.of(context).colorScheme.background.withOpacity(.06)
          : nowPlaying.repState == RepState.up
              ? Theme.of(context).colorScheme.primary.withOpacity(.06)
              : Theme.of(context).colorScheme.secondary.withOpacity(.06),
      child: child,
      height: height,
      width: width,
      alignment: alignment,
      decoration: decoration,
    );
  }

  Color getOverlayColor(double elevation) {
    double opacity;
    switch (elevation.round()) {
      case 0:
        opacity = 0;
        break;
      case 1:
        opacity = 0.05;
        break;
      case 2:
        opacity = 0.07;
        break;
      case 3:
        opacity = 0.08;
        break;
      case 4:
        opacity = 0.09;
        break;
      case 6:
        opacity = 0.11;
        break;
      case 7:
        opacity = 0.11;
        break;
      default:
        opacity = 0;
    }
    return Colors.white.withOpacity(opacity);
  }
}
