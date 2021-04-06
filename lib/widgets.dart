import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'classes.dart';
import 'package:animations/animations.dart';
import 'providers.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'exercise_page.dart';
import 'plan_page.dart';
import 'dart:async';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text(''),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Discard changes?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Discard'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}

class AnimatedBottomBar extends StatelessWidget {
  const AnimatedBottomBar({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return provider.Consumer2<NowPlaying, MenuProvider>(
      builder: (context, nowPlaying, menuProvider, mychild) => Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Theme.of(context).colorScheme.surface.withOpacity(1),
        elevation: 8,
        child: AnimatedContainer(
          duration: menuProvider.navBarTransitionDuration,
          height: !menuProvider.showNavBar
              ? 0
              : nowPlaying.empty
                  ? (menuProvider.inPlanPage || menuProvider.inExercisePage
                      ? 0
                      : menuProvider.navBarBarHeight)
                  : (menuProvider.inPlanPage || menuProvider.inExercisePage
                      ? menuProvider.playCardHeight
                      : menuProvider.navBarBarHeight +
                          menuProvider.playCardHeight),
          child: SingleChildScrollView(
            controller: ScrollController(),
            reverse: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard(
      {Key key,
      @required this.plan,
      this.height = 200,
      this.width = 200,
      this.image,
      this.onTap})
      : super(key: key);

  final Plan plan;
  final double height;
  final double width;
  final String image;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) => Card(
        semanticContainer: false,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2))),
        color: Theme.of(context).colorScheme.primary,
        margin: EdgeInsets.all(0),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.center,
          children: [
            Image.asset(
              image,
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
            InkWell(
              autofocus: true,
              onTap: () async {
                if (onTap != null) await onTap();
                // provider.Provider.of<MenuProvider>(context, listen: false)
                //     .showNavBar = false;
                context.read<MenuProvider>().openPlan = plan;
                context.read<MenuProvider>().inPlanPage = true;
                // Timer(
                //     provider.Provider.of<MenuProvider>(context, listen: false)
                //         .navBarTransitionWait, () {
                //   provider.Provider.of<MenuProvider>(context, listen: false)
                //       .showNavBar = true;
                //   provider.Provider.of<MenuProvider>(context, listen: false)
                //       .inPlanPage = true;
                // });
              },
              child: Container(
                margin: EdgeInsets.all(0),
                height: height,
                width: width,
                decoration: BoxDecoration(
                    border: Border.all(width: 0),
                    gradient: LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [
                          Colors.black.withOpacity(.90),
                          Colors.black.withOpacity(.0)
                        ])),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .apply(color: Colors.white, fontWeightDelta: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                            plan.exercises.length.pluralString('exercise'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .apply(color: Colors.white.withAlpha(190))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final Widget leading;
  final Future<void> Function() onTap;

  AnimatedExerciseTile(
      {Key key, @required this.exercise, this.leading, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseTile(
        leading: leading,
        exercise: exercise,
        onTap: () async {
          if (onTap != null) await onTap();
          context.read<MenuProvider>().openExercise = exercise;
          context.read<MenuProvider>().inExercisePage = true;
        });
  }
}

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    Key key,
    @required this.exercise,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  final Widget leading;
  final Widget trailing;
  final Exercise exercise;
  final bool selected;
  final Function() onTap;

  String get tileDuration {
    return Duration(seconds: exercise.duration.round()).minutesSeconds();
  }

  String get tileTitle {
    return exercise.name +
        '  ·  ' +
        exercise.reps.pluralString('rep') +
        ', ' +
        exercise.sets.pluralString('set');
  }

  String get structString {
    return exercise.reps.pluralString('rep') +
        ', ' +
        exercise.sets.pluralString('set');
  }

  String get tileSubtitle {
    return exercise.secsUp.pluralString('sec') +
        ' up, ' +
        exercise.secsDown.pluralString('sec') +
        ' down, ' +
        exercise.secsRest.pluralString('sec') +
        ' rest';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: ListTile(
        selected: selected,
        tileColor: Colors.transparent,
        selectedTileColor: Theme.of(context).focusColor.withOpacity(0.05),
        onTap: onTap,
        leading: leading,
        trailing: trailing,
        title:
            Text(exercise.name, style: Theme.of(context).textTheme.subtitle1),
        subtitle: Text(tileDuration + '  ·  ' + structString,
            style: Theme.of(context).textTheme.bodyText2.apply(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(.6))),
      ),
    );
  }
}

// class AnimatedFAB extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return provider.Consumer<MenuProvider>(
//       builder: (context, menuProvider, child) => OpenContainer(
//         transitionDuration: menuProvider.pageTransitionDuration,
//         useRootNavigator: true,
//         closedShape: CircleBorder(),
//         closedElevation: 6,
//         closedColor: Theme.of(context).colorScheme.secondary,
//         closedBuilder: (context, action) => FloatingActionButton(
//           heroTag: menuProvider.tabMenu,
//           key: ValueKey(menuProvider.tabMenu),
//           backgroundColor: Theme.of(context).colorScheme.secondary,
//           child: Icon(Icons.add),
//           onPressed: () {
//             menuProvider.showNavBar = false;
//             action();
//             Timer(menuProvider.navBarTransitionWait, () {
//               menuProvider.showNavBar = true;
//             });
//             if (menuProvider.tabMenu == TabMenu.exercises)
//               menuProvider.inExercisePage = true;
//             else
//               menuProvider.inPlanPage = true;
//           },
//         ),
//         onClosed: (_) {
//           if (menuProvider.tabMenu == TabMenu.exercises) {
//             provider.Provider.of<MenuProvider>(context, listen: false)
//                 .showNavBar = true;
//             provider.Provider.of<MenuProvider>(context, listen: false)
//                 .inExercisePage = false;
//           } else {
//             provider.Provider.of<MenuProvider>(context, listen: false)
//                 .showNavBar = true;
//             provider.Provider.of<MenuProvider>(context, listen: false)
//                 .inPlanPage = false;
//           }
//         },
//         openBuilder: (context, action) {
//           if (menuProvider.tabMenu == TabMenu.exercises) {
//             return ExercisePage(
//               key: ValueKey(menuProvider.tabMenu),
//             );
//           } else {
//             return PlanPage(
//               key: ValueKey(menuProvider.tabMenu),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

class PlayCard extends StatefulWidget {
  final BuildContext context;

  const PlayCard(
      {Key key, this.context, this.action, this.progressOnTop = false})
      : super(key: key);
  final void Function() action;
  final bool progressOnTop;

  @override
  _PlayCardState createState() => _PlayCardState();
}

class _PlayCardState extends State<PlayCard>
    with SingleTickerProviderStateMixin {
  AnimationController ticker;

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
    return provider.Consumer<NowPlaying>(builder: (context, nowPlaying, child) {
      return InkWell(
        onTap: widget.action,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 16, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 40, height: 40),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8),
                            child: Container(
                              // color: Colors.black,
                              width: MediaQuery.of(context).size.width -
                                  (16 + 40 + 16 + 8 + 48 * 3 + 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                nowPlaying.currentSet
                                                    .cardinal() +
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
                                  nowPlaying.plan != null &&
                                          nowPlaying.plan.name != ''
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
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
                                        )
                                      : SizedBox(height: 0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          provider.Consumer<Progress>(
                            builder: (context, progress, child) => IconButton(
                                splashRadius: 24,
                                icon: Icon(Icons.skip_previous),
                                onPressed: progress.time != 0
                                    ? nowPlaying.skipPrevious
                                    : null),
                          ),
                          IconButton(
                              splashRadius: 24,
                              icon: Icon(nowPlaying.empty || !nowPlaying.playing
                                  ? Icons.play_arrow
                                  : Icons.pause),
                              onPressed: !nowPlaying.empty && !nowPlaying.ended
                                  ? nowPlaying.togglePlay
                                  : null),
                          IconButton(
                              splashRadius: 24,
                              icon: Icon(Icons.skip_next),
                              onPressed: !nowPlaying.empty && !nowPlaying.ended
                                  ? nowPlaying.skipNext
                                  : null)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  provider.Consumer<Progress>(
                    builder: (context, progress, child) =>
                        buildLinearPercentIndicator(
                            context, progress.percent, !nowPlaying.playing),
                  ),
                  // Divider(
                  //   color:
                  //       Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                  //   height: .5,
                  // ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  LinearPercentIndicator buildLinearPercentIndicator(
      BuildContext context, double percent, bool animate) {
    return LinearPercentIndicator(
      curve: Curves.fastOutSlowIn,
      animation: animate,
      animationDuration: 300,
      animateFromLastPercent: true,
      percent: percent,
      lineHeight: 1.5,
      progressColor: Theme.of(context).accentColor,
      backgroundColor: Theme.of(context).accentColor.withAlpha(40),
      padding: EdgeInsets.all(0),
    );
  }
}

class TimerIndicator extends StatefulWidget {
  const TimerIndicator({
    Key key,
    this.animation,
    this.isSmall = true,
  }) : super(key: key);

  final Animation<double> animation;
  final bool isSmall;

  @override
  _TimerIndicatorState createState() => _TimerIndicatorState();
}

class _TimerIndicatorState extends State<TimerIndicator> {
  final int animationDuration = 300;

  final double maxOuterRadius = 200.0;
  final double maxOuterLineWidth = 12.0;
  final double maxInnerRadius = 155.0;
  final double maxInnerLineWidth = 12.0;
  final double maxContainerWidth = 90;
  final double maxContainerHeight = 60;

  final double minOuterRadius = 40.0;
  final double minOuterLineWidth = 4.0;
  final double minInnerRadius = 23.0;
  final double minInnerLineWidth = 4.0;
  final double minContainerWidth = 0;
  final double minContainerHeight = 0;

  double value;

  double get scale => value * 3 - 2 > 0 ? value * 3 - 2 : 0;

  @override
  void initState() {
    super.initState();
    if (widget.animation != null) {
      value = widget.animation.value;
      widget.animation.addListener(() {
        if (mounted)
          setState(() {
            value = widget.animation.value;
          });
      });
    } else {
      if (widget.isSmall)
        value = 0.0;
      else
        value = 1.0;
    }
  }

  // @override
  // void dispose() {
  //   widget.animation.removeListener(() {
  //     setState(() {
  //       value = widget.animation.value;
  //     });
  //   });
  //   super.dispose();
  // }

  double interpolate(double start, double end) {
    return (end - start) * value + start;
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) {
        final showFirst = !nowPlaying.inSet && !nowPlaying.inEnd;

        return Stack(
          children: [
            AnimatedOpacity(
              opacity: showFirst ? 1 : 0,
              duration: Duration(milliseconds: animationDuration),
              child: provider.Consumer<Progress>(
                builder: (context, progress, child) => CircularPercentIndicator(
                  curve: Curves.fastOutSlowIn,
                  animation: false, //!nowPlaying.playing,
                  animationDuration: animationDuration,
                  animateFromLastPercent: false, //true,
                  radius: interpolate(
                    minOuterRadius,
                    maxOuterRadius,
                  ),
                  lineWidth: interpolate(
                    minOuterLineWidth,
                    maxOuterLineWidth,
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  percent:
                      !nowPlaying.inSet ? progress.setPercent.toDouble() : 0.0,
                  progressColor: Color.alphaBlend(
                      Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                      Theme.of(context).colorScheme.background),
                  backgroundColor:
                      Theme.of(context).colorScheme.onBackground.withAlpha(40),
                  center: CircularPercentIndicator(
                    curve: Curves.fastOutSlowIn,
                    animation: false, //!nowPlaying.playing,
                    animationDuration: animationDuration,
                    animateFromLastPercent: false, // true,
                    radius: interpolate(
                      minInnerRadius,
                      maxInnerRadius,
                    ),
                    lineWidth: interpolate(
                      minInnerLineWidth,
                      maxInnerLineWidth,
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    percent: progress.percent.toDouble(),
                    progressColor: Theme.of(context).accentColor,
                    backgroundColor:
                        Theme.of(context).accentColor.withAlpha(30),
                    center: ClipOval(
                      child: SizedOverflowBox(
                        size: Size.square(scale * maxContainerWidth),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            width: maxContainerWidth,
                            height: maxContainerHeight,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                        nowPlaying.inReady ? 'Ready' : 'Rest',
                                        overflow: TextOverflow.clip,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2
                                            .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontSizeFactor: 0.4,
                                            )
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                  ),
                                  !nowPlaying.inEnd
                                      ? Text(
                                          nowPlaying.currentSet.cardinal() +
                                              ' set',
                                          overflow: TextOverflow.clip,
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .apply(
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      fontWeightDelta: 2))
                                      : SizedBox(height: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: showFirst ? 0 : 1,
              duration: Duration(milliseconds: animationDuration),
              child: provider.Consumer<Progress>(
                builder: (context, progress, child) => CircularPercentIndicator(
                  curve: Curves.fastOutSlowIn,
                  animation: false, //!nowPlaying.playing,
                  animationDuration: animationDuration,
                  animateFromLastPercent: false, //true,
                  radius: interpolate(
                    minOuterRadius,
                    maxOuterRadius,
                  ),
                  lineWidth: interpolate(
                    minOuterLineWidth,
                    maxOuterLineWidth,
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: progress.setPercent.toDouble(),
                  progressColor: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(40),
                  center: CircularPercentIndicator(
                    curve: Curves.fastOutSlowIn,
                    animation: false, //!nowPlaying.playing,
                    animationDuration: animationDuration,
                    animateFromLastPercent: false, // true,
                    radius: interpolate(
                      minInnerRadius,
                      maxInnerRadius,
                    ),
                    lineWidth: interpolate(
                      minInnerLineWidth,
                      maxInnerLineWidth,
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    percent: progress.percent.toDouble(),
                    progressColor: Theme.of(context).accentColor,
                    backgroundColor:
                        Theme.of(context).accentColor.withAlpha(40),
                    center: ClipOval(
                      child: SizedOverflowBox(
                        size: Size.square(scale * maxContainerWidth),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            width: maxContainerWidth,
                            height: maxContainerHeight,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      nowPlaying.inSet
                                          ? nowPlaying.currentRep
                                              .pluralString('rep')
                                          : 'Done',
                                      overflow: TextOverflow.clip,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSizeFactor: 0.4,
                                          )
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                      !nowPlaying.inEnd
                                          ? nowPlaying.currentSet.cardinal() +
                                              ' set'
                                          : nowPlaying.currentSet
                                              .pluralString('set'),
                                      overflow: TextOverflow.clip,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .apply(
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontWeightDelta: 2)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ExpandableSheet extends StatefulWidget {
  ExpandableSheet({
    Key key,
    this.bottomLayer,
    @required this.topLayer,
    this.initialHeight = 72,
    @required this.controller,
    this.showController,
    this.onDismiss,
  }) : super(key: key);

  final Widget bottomLayer;
  final Widget topLayer;
  final double initialHeight;
  final void Function() onDismiss;

  final AnimationController controller;
  final AnimationController showController;

  @override
  _ExpandableSheetState createState() => _ExpandableSheetState();
}

class _ExpandableSheetState extends State<ExpandableSheet>
    with SingleTickerProviderStateMixin {
  bool fromStart = true;
  bool triedToDismiss = false;

  AnimationController showController;
  Animation<double> showHeight;
  Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    showController =
        widget.showController ?? AnimationController(vsync: this, value: 1);

    showHeight = Tween<double>(begin: 0, end: widget.initialHeight)
        .animate(showController);

    opacity = Tween<double>(begin: 0, end: 0.32).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(
          0,
          0.5,
          curve: Curves.linear,
        ),
      ),
    );

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.controller.isDismissed)
          return true;
        else {
          widget.controller.fling(velocity: -1);
          return false;
        }
      },
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            Animation<double> height = Tween<double>(
              begin: widget.initialHeight,
              end: constraints.maxHeight,
            ).animate(widget.controller);

            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Positioned(
                  top: 0,
                  child: AnimatedBuilder(
                    animation: showController,
                    builder: (context, child) => SizedBox(
                      height: constraints.maxHeight - showHeight.value,
                      width: constraints.maxWidth,
                      child: widget.bottomLayer,
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: widget.controller.isDismissed,
                  child: SizedBox.expand(
                    child: FadeTransition(
                      opacity: opacity,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: showController,
                      builder: (context, child) {
                        Animation<double> top1 = Tween<double>(
                                begin: constraints.maxHeight,
                                end: constraints.maxHeight -
                                    widget.initialHeight)
                            .animate(showController);

                        Animation<double> top2 = Tween<double>(
                                begin: constraints.maxHeight -
                                    widget.initialHeight,
                                end: 0)
                            .animate(widget.controller);

                        return Positioned(
                          top: !showController.isCompleted
                              ? top1.value
                              : top2.value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (widget.controller.isDismissed)
                            widget.controller.fling();
                        },
                        onVerticalDragUpdate: (details) {
                          final newValue = widget.controller.value -
                              details.primaryDelta / constraints.maxHeight;
                          if (!triedToDismiss &&
                              newValue >= 0 &&
                              newValue <= 1) {
                            widget.controller.value = newValue;
                          } else if (newValue < 0 &&
                              widget.controller.isDismissed) {
                            final newShowValue = widget.showController.value -
                                details.primaryDelta / widget.initialHeight;
                            if (newShowValue >= 0 && newShowValue <= 1) {
                              widget.showController.value = newShowValue;
                              setState(() {
                                triedToDismiss = true;
                              });
                            }
                          }
                        },
                        onVerticalDragEnd: (details) {
                          if (triedToDismiss) {
                            setState(() {
                              triedToDismiss = false;
                            });
                            if (showController.value < 0.85) {
                              showController.fling(velocity: -1).then((_) {
                                if (widget.onDismiss != null)
                                  widget.onDismiss();
                              });
                            } else {
                              showController.fling();
                            }
                          }

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
                      ),
                    );
                  },
                  child: widget.topLayer,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
