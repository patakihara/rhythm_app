import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'classes.dart';
import 'package:animations/animations.dart';
import 'play_page.dart';
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

class AnimatedPlayCard extends StatelessWidget {
  const AnimatedPlayCard({
    Key key,
    this.progressOnTop = false,
  }) : super(key: key);

  final bool progressOnTop;

  @override
  Widget build(BuildContext context) {
    return provider.Consumer2<NowPlaying, MenuProvider>(
      builder: (context, nowPlaying, menuProvider, child) {
        final action = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayPage()),
          );
        };
        return AnimatedContainer(
          duration: menuProvider.navBarTransitionDuration,
          height: nowPlaying.empty ? 0 : menuProvider.playCardHeight,
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity < 0) {
                  action();
                }
              },
              onTap: action,
              child: PlayCard(
                key: Key('playCardSmall'),
                context: context,
                action: action,
                progressOnTop: progressOnTop,
              ),
            ),
          ),
        );
      },
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
      builder: (context, nowPlaying, child) => OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration:
            provider.Provider.of<MenuProvider>(context).pageTransitionDuration,
        tappable: false,
        useRootNavigator: true,
        openColor: Theme.of(context).colorScheme.background,
        closedColor: Theme.of(context).colorScheme.background,
        closedElevation: 0,
        openElevation: 1,
        onClosed: (_) {
          provider.Provider.of<MenuProvider>(context, listen: false)
              .showNavBar = true;
          provider.Provider.of<MenuProvider>(context, listen: false)
              .inPlanPage = false;
        },
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2))),
        closedBuilder: (BuildContext c, VoidCallback action) => Card(
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
                  provider.Provider.of<MenuProvider>(context, listen: false)
                      .showNavBar = false;
                  action();
                  Timer(
                      provider.Provider.of<MenuProvider>(context, listen: false)
                          .navBarTransitionWait, () {
                    provider.Provider.of<MenuProvider>(context, listen: false)
                        .showNavBar = true;
                    provider.Provider.of<MenuProvider>(context, listen: false)
                        .inPlanPage = true;
                  });
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
        openBuilder: (BuildContext c, VoidCallback action) =>
            PlanPage(plan: plan),
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
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration:
          provider.Provider.of<MenuProvider>(context).pageTransitionDuration,
      tappable: false,
      useRootNavigator: true,
      closedElevation: 1,
      openElevation: 1,
      closedColor: Theme.of(context).colorScheme.surface,
      openColor: Theme.of(context).colorScheme.surface,
      onClosed: (_) {
        provider.Provider.of<MenuProvider>(context, listen: false).showNavBar =
            true;
        provider.Provider.of<MenuProvider>(context, listen: false)
            .inExercisePage = false;
      },
      closedShape: RoundedRectangleBorder(),
      closedBuilder: (BuildContext c, VoidCallback action) => ExerciseTile(
          leading: leading,
          exercise: exercise,
          onTap: () async {
            if (onTap != null) await onTap();
            provider.Provider.of<MenuProvider>(context, listen: false)
                .showNavBar = false;
            action();
            Timer(
                provider.Provider.of<MenuProvider>(context, listen: false)
                    .navBarTransitionWait, () {
              provider.Provider.of<MenuProvider>(context, listen: false)
                  .showNavBar = true;
            });
            provider.Provider.of<MenuProvider>(context, listen: false)
                .inExercisePage = true;
          }),
      openBuilder: (BuildContext c, VoidCallback action) =>
          ExercisePage(exercise: exercise),
    );
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
  final void Function() onTap;

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
                          HeroTimerIndicator(
                            isSmall: true,
                          ),
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
                          IconButton(
                              splashRadius: 24,
                              icon: Icon(Icons.skip_previous),
                              onPressed: nowPlaying.time != 0
                                  ? nowPlaying.skipPrevious
                                  : null),
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
                  buildLinearPercentIndicator(
                      context, nowPlaying.percent, !nowPlaying.playing),
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

class HeroTimerIndicator extends StatelessWidget {
  const HeroTimerIndicator({
    Key key,
    this.isSmall = true,
  }) : super(key: key);

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'timerIndicator',
      child: TimerIndicator(
        isSmall: isSmall,
      ),
      flightShuttleBuilder: (context, animation, arg1, arg2, arg3) {
        return TimerIndicator(
          animation: animation,
          isSmall: isSmall,
        );
      },
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

  @override
  void initState() {
    super.initState();
    if (widget.animation != null)
      widget.animation.addListener(() {
        setState(() {
          if (widget.isSmall)
            value = widget.animation.value;
          else
            value = 1 - widget.animation.value;
        });
      });
    else {
      if (widget.isSmall)
        value = 0.0;
      else
        value = 1.0;
    }
  }

  double interpolate(double start, double end) {
    return (end - start) * value + start;
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) => AnimatedCrossFade(
        duration: Duration(milliseconds: animationDuration),
        firstCurve: Curves.fastOutSlowIn,
        sizeCurve: Curves.fastOutSlowIn,
        secondCurve: Curves.fastOutSlowIn,
        crossFadeState: !nowPlaying.inSet && !nowPlaying.inEnd
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: CircularPercentIndicator(
          curve: Curves.fastOutSlowIn,
          animation: !nowPlaying.playing,
          animationDuration: animationDuration,
          animateFromLastPercent: true,
          radius: interpolate(
            minOuterRadius,
            maxOuterRadius,
          ),
          lineWidth: interpolate(
            minOuterLineWidth,
            maxOuterLineWidth,
          ),
          circularStrokeCap: CircularStrokeCap.round,
          percent: !nowPlaying.inSet ? nowPlaying.setPerc.toDouble() : 0.0,
          progressColor: Color.alphaBlend(
              Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              Theme.of(context).colorScheme.background),
          backgroundColor:
              Theme.of(context).colorScheme.onBackground.withAlpha(40),
          center: CircularPercentIndicator(
            curve: Curves.fastOutSlowIn,
            animation: !nowPlaying.playing,
            animationDuration: animationDuration,
            animateFromLastPercent: true,
            radius: interpolate(
              minInnerRadius,
              maxInnerRadius,
            ),
            lineWidth: interpolate(
              minInnerLineWidth,
              maxInnerLineWidth,
            ),
            circularStrokeCap: CircularStrokeCap.round,
            percent: nowPlaying.percent.toDouble(),
            progressColor: Theme.of(context).accentColor,
            backgroundColor: Theme.of(context).accentColor.withAlpha(30),
            center: Opacity(
              opacity: value,
              child: Container(
                width: interpolate(
                  minContainerWidth,
                  maxContainerWidth,
                ),
                height: interpolate(
                  minContainerHeight,
                  maxContainerHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(nowPlaying.inReady ? 'Ready' : 'Rest',
                          overflow: TextOverflow.fade,
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              .apply(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSizeFactor: 0.4,
                              )
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    !nowPlaying.inEnd
                        ? Text(nowPlaying.currentSet.cardinal() + ' set',
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subtitle2.apply(
                                color: Theme.of(context).accentColor,
                                fontWeightDelta: 2))
                        : SizedBox(height: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        secondChild: CircularPercentIndicator(
          curve: Curves.fastOutSlowIn,
          animation: !nowPlaying.playing,
          animationDuration: animationDuration,
          animateFromLastPercent: true,
          radius: interpolate(
            minOuterRadius,
            maxOuterRadius,
          ),
          lineWidth: interpolate(
            minOuterLineWidth,
            maxOuterLineWidth,
          ),
          circularStrokeCap: CircularStrokeCap.round,
          percent: nowPlaying.setPerc.toDouble(),
          progressColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(40),
          center: CircularPercentIndicator(
            curve: Curves.fastOutSlowIn,
            animation: !nowPlaying.playing,
            animationDuration: animationDuration,
            animateFromLastPercent: true,
            radius: interpolate(
              minInnerRadius,
              maxInnerRadius,
            ),
            lineWidth: interpolate(
              minInnerLineWidth,
              maxInnerLineWidth,
            ),
            circularStrokeCap: CircularStrokeCap.round,
            percent: nowPlaying.percent.toDouble(),
            progressColor: Theme.of(context).accentColor,
            backgroundColor: Theme.of(context).accentColor.withAlpha(40),
            center: Opacity(
              opacity: value,
              child: Container(
                width: interpolate(
                  minContainerWidth,
                  maxContainerWidth,
                ),
                height: interpolate(
                  minContainerHeight,
                  maxContainerHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        nowPlaying.inSet
                            ? nowPlaying.currentRep.pluralString('rep')
                            : 'Done',
                        overflow: TextOverflow.fade,
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            .apply(
                              color: Theme.of(context).colorScheme.primary,
                              fontSizeFactor: 0.4,
                            )
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                        !nowPlaying.inEnd
                            ? nowPlaying.currentSet.cardinal() + ' set'
                            : nowPlaying.currentSet.pluralString('set'),
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.subtitle2.apply(
                            color: Theme.of(context).accentColor,
                            fontWeightDelta: 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
