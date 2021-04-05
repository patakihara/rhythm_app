import 'dart:async';

import 'package:Rhythm/play_page.dart';
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

class MenuPage extends StatefulWidget {
  MenuPage({Key key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController showController;
  // final height = 50.0;

  // AnimationController myController;
  Animation<double> secondChildFadeAnimation;
  Animation<double> firstChildFadeAnimation;
  Animation<Alignment> alignmentAnim;
  Animation<double> sizeAnimation;
  Animation<double> topAnim;
  Animation<double> leftAnim;

  final double bigPlayCardHeight = 56.0 * 5;
  bool openQueue = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    showController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5000));

    // Timer(Duration(seconds: 2), () {
    //   showController.animateTo(1);
    // });

    secondChildFadeAnimation =
        Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.55,
        0.85,
        curve: Curves.ease,
      ),
    ));
    firstChildFadeAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.05,
        0.50,
        curve: Curves.ease,
      ),
    ));

    alignmentAnim = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    final finalSize = 150.0;

    // final freeAreaHeight = MediaQuery.of(context).size.height -
    //     playCardHeight -
    //     MediaQuery.of(context).viewPadding.top -
    //     56;
    // final top = freeAreaHeight / 2 -
    //     finalSize / 2 +
    //     MediaQuery.of(context).viewPadding.top +
    //     56;

    // topAnim = Tween<double>(begin: 0, end: top).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Interval(
    //       72 / MediaQuery.of(context).size.height,
    //       1,
    //       curve: Curves.linear,
    //     ),
    //   ),
    // );

    leftAnim = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          72 / MediaQuery.of(context).size.height,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    sizeAnimation = Tween<double>(begin: 50, end: finalSize).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.addListener(() {
      // print(_controller.value * MediaQuery.of(context).size.height);
    });
  }

  // void _expand() {
  //   print("expand");
  //   _controller.launchTo(_controller.value, _controller.upperBound,
  //       velocity: 2);
  // }

  CrossFadeState myCol = CrossFadeState.showFirst;

  @override
  Widget build(BuildContext context) {
    // if (!context.watch<NowPlaying>().empty && showController.isDismissed) {
    //   showController.fling();
    //   print('flinged up');
    // } else if (context.watch<NowPlaying>().empty &&
    //     showController.isCompleted) {
    //   showController.fling(velocity: -1);
    //   print('flinged down');
    // }
    return Scaffold(
      // appBar: AppBar(
      // title: Text(
      //   "Menu",
      //   style: TextStyle(color: Colors.cyan[900]),
      // ),
      // ),
      body: Container(
        child: Consumer<NowPlaying>(
          builder: (context, nowPlaying, child) {
            if (!nowPlaying.empty && showController.isDismissed) {
              showController.fling();
            } else if (nowPlaying.empty && showController.isCompleted) {
              showController.fling(velocity: -1);
            }
            return MySheet(
              bottomLayer: _getLowerLayer(),
              topLayer: _getUpperLayer(),
              controller: _controller,
              showController: showController,
              // show: !context.watch<NowPlaying>().empty,
              // onTap: _expand,
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: "flt3",
      //   onPressed: _expand,
      //   backgroundColor: Colors.cyan[900],
      //   foregroundColor: Colors.cyan[400],
      //   child: Icon(Icons.vertical_align_top),
      // ),
    );
  }

  Widget _getLowerLayer() {
    return Consumer<Library>(builder: (context, library, child) {
      if (library.plans.isNotEmpty) return PlanPage(plan: library.plans.first);
      return Container(
        decoration: BoxDecoration(color: Colors.cyan[100]),
      );
    });

    return Container(
      decoration: BoxDecoration(color: Colors.cyan[100]),
    );
  }

  Widget _getUpperLayer() {
    return Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox.expand(
              child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: secondChildFadeAnimation.value < 0.089
                            ? 0
                            : secondChildFadeAnimation.value,
                        child: nowPlaying.empty
                            ? Container()
                            : Stack(
                                children: [
                                  Material(
                                    elevation: 6,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                  AnimatedContainer(
                                    curve: Curves.fastOutSlowIn,
                                    duration: Duration(milliseconds: 500),
                                    color: nowPlaying.repState == RepState.rest
                                        ? Theme.of(context)
                                            .colorScheme
                                            .background
                                        : nowPlaying.repState == RepState.up
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(.08)
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(.08),
                                  ),
                                  Scaffold(
                                    backgroundColor: Colors.transparent,
                                    appBar: AppBar(
                                      // title: Text('Timer'),
                                      backgroundColor: Colors.transparent,
                                      iconTheme: Theme.of(context).iconTheme,
                                      textTheme: Theme.of(context)
                                          .textTheme
                                          .apply(
                                              bodyColor: Theme.of(context)
                                                  .iconTheme
                                                  .color),
                                      elevation: 0,
                                      actions: [
                                        IconButton(
                                            padding: EdgeInsets.all(16),
                                            icon: Icon(
                                              Icons.stop,
                                            ),
                                            onPressed: () {
                                              _controller
                                                  .fling(velocity: -1)
                                                  .then((value) =>
                                                      nowPlaying.clear());
                                              // Timer(
                                              //   Provider.of<MenuProvider>(
                                              //     context,
                                              //     listen: false,
                                              //   ).pageTransitionDuration,
                                              //   () => Provider.of<NowPlaying>(
                                              //     context,
                                              //     listen: false,
                                              //   ).clear(),
                                              // );
                                              // Navigator.pop(context);
                                            }),
                                      ],
                                      leading: IconButton(
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                        onPressed: () {
                                          _controller.fling(velocity: -1);
                                        },
                                      ),
                                    ),
                                    extendBodyBehindAppBar: false,
                                    body: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // SizedBox(height: 56 + MediaQuery.of(context).viewInsets.top),
                                          Expanded(
                                              child: Center(
                                            child: SingleChildScrollView(
                                              physics: ClampingScrollPhysics(),
                                              // child: HeroTimerIndicator(
                                              //   isSmall: false,
                                              // ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Stack(
                        children: [
                          Opacity(
                            opacity: firstChildFadeAnimation.value,
                            child: IgnorePointer(
                              ignoring: !_controller.isDismissed,
                              child: SizedBox(
                                height: 72,
                                child: PlayCard(),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: _controller.value *
                                    (56 +
                                        MediaQuery.of(context).viewPadding.top),
                              ),
                              Align(
                                alignment: alignmentAnim.value,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: leftAnim.value,
                                    // top: topAnim.value,
                                  ),
                                  child: TimerIndicator(
                                    animation: _controller,
                                    isSmall: true,
                                  ),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.red,
                                  //     borderRadius: BorderRadius.circular(8.0),
                                  //   ),
                                  //   padding: const EdgeInsets.all(0),
                                  //   width: sizeAnimation.value,
                                  //   height: sizeAnimation.value,
                                  // ),
                                ),
                              ),
                              SizedBox(
                                height: _controller.value * (bigPlayCardHeight),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Opacity(
                              opacity: secondChildFadeAnimation.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height:
                                        _controller.value * (bigPlayCardHeight),
                                    child: SingleChildScrollView(
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        height: bigPlayCardHeight,
                                        child: Card(
                                          elevation: 6,
                                          margin: EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              LinearPercentIndicator(
                                                curve: Curves.fastOutSlowIn,
                                                animation: !nowPlaying.playing,
                                                animateFromLastPercent: true,
                                                animationDuration: 300,
                                                percent: nowPlaying.percent,
                                                lineHeight: 2,
                                                progressColor: Theme.of(context)
                                                    .accentColor,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .accentColor
                                                        .withAlpha(60),
                                                padding: EdgeInsets.all(0),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0,
                                                    left: 8.0,
                                                    right: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      nowPlaying.time
                                                          .minutesSeconds(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption,
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
                                              Column(
                                                children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                              nowPlaying
                                                                  .exercise
                                                                  .name,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline5
                                                                  .apply(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onBackground
                                                                          .withAlpha(
                                                                              255))),
                                                          nowPlaying.plan
                                                                      .name !=
                                                                  ''
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      nowPlaying
                                                                          .plan
                                                                          .name,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .subtitle2
                                                                          .apply(
                                                                              color: Theme.of(context).colorScheme.onBackground.withAlpha(160))),
                                                                )
                                                              : SizedBox(
                                                                  height: 0),
                                                        ],
                                                      )),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        IconButton(
                                                            splashRadius:
                                                                56 / 2,
                                                            icon: Icon(MdiIcons
                                                                .skipBackward),
                                                            onPressed: nowPlaying
                                                                    .isFirst
                                                                ? null
                                                                : nowPlaying
                                                                    .skipBackward),
                                                        IconButton(
                                                            splashRadius:
                                                                56 / 2,
                                                            icon: Icon(Icons
                                                                .skip_previous),
                                                            onPressed: nowPlaying
                                                                        .time !=
                                                                    0
                                                                ? nowPlaying
                                                                    .skipPrevious
                                                                : null),
                                                        FloatingActionButton(
                                                          shape: CircleBorder(),
                                                          disabledElevation: 0,
                                                          // elevation: 8,
                                                          backgroundColor: !nowPlaying
                                                                  .ended
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary
                                                              : Theme.of(
                                                                      context)
                                                                  .disabledColor,
                                                          child: Icon(
                                                            !nowPlaying.playing
                                                                ? Icons
                                                                    .play_arrow
                                                                : Icons.pause,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSecondary,
                                                          ),
                                                          onPressed: !nowPlaying
                                                                  .ended
                                                              ? nowPlaying
                                                                  .togglePlay
                                                              : null,
                                                        ),
                                                        IconButton(
                                                            splashRadius:
                                                                56 / 2,
                                                            icon: Icon(Icons
                                                                .skip_next),
                                                            onPressed:
                                                                !nowPlaying
                                                                        .ended
                                                                    ? nowPlaying
                                                                        .skipNext
                                                                    : null),
                                                        IconButton(
                                                            splashRadius:
                                                                56 / 2,
                                                            icon: Icon(MdiIcons
                                                                .skipForward),
                                                            onPressed: nowPlaying
                                                                    .isLast
                                                                ? null
                                                                : nowPlaying
                                                                    .skipForward),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16.0),
                                                    child: AnimatedContainer(
                                                      curve:
                                                          Curves.fastOutSlowIn,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      color: nowPlaying
                                                                  .repState ==
                                                              RepState.rest
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .background
                                                              .withOpacity(.5)
                                                          : nowPlaying.repState ==
                                                                  RepState.up
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                      .06)
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary
                                                                  .withOpacity(
                                                                      .06),
                                                      child: ListTile(
                                                        trailing: Icon(openQueue
                                                            ? Icons
                                                                .keyboard_arrow_down
                                                            : Icons
                                                                .keyboard_arrow_up),
                                                        leading: Icon(Icons
                                                            .playlist_play),
                                                        dense: false,
                                                        onTap: () {
                                                          setState(() =>
                                                              openQueue =
                                                                  !openQueue);
                                                        },
                                                        title: Text(
                                                            nowPlaying.exerciseIndex <
                                                                    nowPlaying
                                                                            .plan
                                                                            .exerciseNames
                                                                            .length -
                                                                        1
                                                                ? 'Up next: ' +
                                                                    nowPlaying
                                                                            .plan
                                                                            .exerciseNames[
                                                                        nowPlaying.exerciseIndex +
                                                                            1]
                                                                : 'Last exercise',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .caption
                                                                .apply(
                                                                    color: Theme.of(
                                                                            context)
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
                                    duration: context
                                        .read<MenuProvider>()
                                        .pageTransitionDuration,
                                    height: () {
                                      if (openQueue &&
                                          _controller.isCompleted) {
                                        return MediaQuery.of(context)
                                                .size
                                                .height -
                                            56 -
                                            MediaQuery.of(context)
                                                .viewPadding
                                                .top -
                                            bigPlayCardHeight;
                                      } else
                                        return 0.0;
                                    }(),
                                    child: Stack(
                                      children: [
                                        ClipRect(
                                          child: AnimatedContainer(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              curve:
                                                  Curves.fastLinearToSlowEaseIn,
                                              duration: context
                                                  .read<MenuProvider>()
                                                  .pageTransitionDuration,
                                              height: () {
                                                if (openQueue) {
                                                  return MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      56 -
                                                      MediaQuery.of(context)
                                                          .viewPadding
                                                          .top -
                                                      bigPlayCardHeight;
                                                } else
                                                  return 0.0;
                                              }(),
                                              child: ListView.builder(
                                                  itemCount: nowPlaying.plan
                                                      .exerciseNames.length,
                                                  itemExtent: 72,
                                                  itemBuilder: (_, int i) {
                                                    bool currentlyPlaying() =>
                                                        nowPlaying
                                                            .exerciseIndex ==
                                                        i;
                                                    bool willPlayLater() =>
                                                        i >
                                                        nowPlaying
                                                            .exerciseIndex;
                                                    bool hasPlayedBefore() =>
                                                        i <
                                                        nowPlaying
                                                            .exerciseIndex;
                                                    return ExerciseTile(
                                                      selected:
                                                          currentlyPlaying(),
                                                      exercise: nowPlaying
                                                          .plan.exercises[i],
                                                      onTap: () {
                                                        if (!currentlyPlaying()) {
                                                          if (willPlayLater())
                                                            while (
                                                                !currentlyPlaying())
                                                              nowPlaying
                                                                  .skipForward();
                                                          else if (hasPlayedBefore())
                                                            while (
                                                                !currentlyPlaying())
                                                              nowPlaying
                                                                  .skipBackward();
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
                          )
                        ],
                      ),
                    ],
                  )));
        },
      ),
    );
  }
}

class MySheet extends StatefulWidget {
  MySheet({
    Key key,
    this.bottomLayer,
    @required this.topLayer,
    this.initialHeight = 72,
    @required this.controller,
    this.show = true,
    this.showController,
  }) : super(key: key);

  final Widget bottomLayer;
  final Widget topLayer;
  final double initialHeight;
  final bool show;

  final AnimationController controller;
  final AnimationController showController;

  @override
  _MySheetState createState() => _MySheetState();
}

class _MySheetState extends State<MySheet> with SingleTickerProviderStateMixin {
  bool fromStart = true;

  AnimationController showController;
  Animation<double> showHeight;

  @override
  void initState() {
    super.initState();

    showController =
        widget.showController ?? AnimationController(vsync: this, value: 1);
    // showController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 1000),
    // );
    showHeight = Tween<double>(begin: 0, end: widget.initialHeight)
        .animate(showController);

    // showController.addListener(() {
    //   setState(() {});
    // });

    widget.controller.addStatusListener((status) {
      if (widget.controller.isCompleted)
        setState(() {
          fromStart = false;
        });
      else if (widget.controller.isDismissed) {
        setState(() {
          fromStart = true;
        });
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (widget.show && showController.isDismissed) {
  //     showController.fling();
  //   } else if (!widget.show && showController.isCompleted) {
  //     showController.fling(velocity: -1);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          SizedBox.expand(child: widget.bottomLayer),
          LayoutBuilder(
            builder: (context, constraints) {
              Animation<double> height = Tween<double>(
                begin: widget.initialHeight,
                end: constraints.maxHeight,
              ).animate(widget.controller);
              return AnimatedBuilder(
                animation: showController,
                builder: (context, child) => SizedBox(
                  height: showController.isCompleted ? null : showHeight.value,
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, child) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (widget.controller.isDismissed)
                            widget.controller.fling();
                          // if (widget.controller.isCompleted)
                          // widget.controller.fling(velocity: -1);
                        },
                        onVerticalDragUpdate: (details) {
                          final newValue = widget.controller.value -
                              details.primaryDelta / constraints.maxHeight;
                          if (newValue >= 0 && newValue <= 1) {
                            widget.controller.value = newValue;
                          }
                          print('updating');
                        },
                        onVerticalDragEnd: (details) {
                          final threshold = 2.0;
                          final velocity =
                              -details.velocity.pixelsPerSecond.dy /
                                  constraints.maxHeight;

                          final velocityCheck = velocity.abs() >= threshold;
                          final positionCheck =
                              (fromStart && widget.controller.value > 0.5) ||
                                  (!fromStart && widget.controller.value < 0.5);

                          print('Velocity is high enough: ' +
                              velocityCheck.toString());
                          print('Position is high enough: ' +
                              positionCheck.toString());
                          print('Coming from start: ' + fromStart.toString());

                          if (velocityCheck)
                            widget.controller.fling(velocity: velocity);
                          else if (positionCheck)
                            widget.controller
                                .fling(velocity: fromStart ? 1 : -1);
                          else
                            widget.controller
                                .fling(velocity: fromStart ? -1 : 1);
                        },
                        child: SizedBox(
                          height: height.value,
                          width: constraints.maxWidth,
                          child: child,
                        ),
                      );
                    },
                    child: widget.topLayer,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
