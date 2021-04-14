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

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
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
            Text('Are you sure you want to delete?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Delete'),
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
          height: false
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
    this.width,
  }) : super(key: key);

  final Widget leading;
  final Widget trailing;
  final Exercise exercise;
  final bool selected;
  final Function() onTap;
  final double width;

  String get tileDuration {
    return exercise.duration.minutesSeconds();
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
    return exercise.ticTime.pluralString('sec') +
        ' up, ' +
        exercise.tocTime.pluralString('sec') +
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

class ExerciseTileSmall extends StatelessWidget {
  const ExerciseTileSmall({
    Key key,
    @required this.exercise,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.width,
  }) : super(key: key);

  final Widget leading;
  final Widget trailing;
  final Exercise exercise;
  final bool selected;
  final Function() onTap;
  final double width;

  String get tileDuration {
    return exercise.duration.minutesSeconds();
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
    return exercise.ticTime.pluralString('sec') +
        ' up, ' +
        exercise.tocTime.pluralString('sec') +
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
        trailing: Text(tileDuration,
            style: Theme.of(context).textTheme.bodyText2.apply(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(.6))),
        title:
            Text(exercise.name, style: Theme.of(context).textTheme.subtitle1),
        // subtitle: Text(tileDuration + '  ·  ' + structString,
        //     style: Theme.of(context).textTheme.bodyText2.apply(
        //         color:
        //             Theme.of(context).colorScheme.onSurface.withOpacity(.6))),
      ),
    );
  }
}

class DismissibleExerciseTile extends StatelessWidget {
  const DismissibleExerciseTile({
    Key key,
    @required this.exercise,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.onDismissed,
  }) : super(key: key);

  final Widget leading;
  final Widget trailing;
  final Exercise exercise;
  final bool selected;
  final Function() onTap;
  final void Function(DismissDirection direction) onDismissed;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      child: ExerciseTileSmall(
        exercise: exercise,
        leading: leading,
        trailing: trailing,
        selected: selected,
        onTap: onTap,
      ),
      onDismissed: onDismissed,
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

class _PlayCardState extends State<PlayCard> with TickerProviderStateMixin {
  AnimationController ticker;

  AnimationController playStateController;

  @override
  void initState() {
    ticker = AnimationController(
        vsync: this, value: 0, duration: Duration(minutes: 1));
    ticker.addListener(() {
      provider.Provider.of<NowPlaying>(context, listen: false).updateTime();
    });
    ticker.repeat();

    playStateController = AnimationController(vsync: this);
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
      if (nowPlaying.playing && playStateController.isDismissed) {
        playStateController.fling();
      } else if (!nowPlaying.playing && playStateController.isCompleted) {
        playStateController.fling(velocity: -1);
      }

      return InkWell(
        onTap: widget.action,
        child: SizedBox(
          height: context.read<MenuProvider>().playCardHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: AlignmentDirectional.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 40, height: 40),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Container(
                            // color: Colors.black,
                            width: MediaQuery.of(context).size.width -
                                (16 + 40 + 16 + 8 + 48 * 3 + 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              padding: EdgeInsets.all(12),
                              splashRadius: 24,
                              icon: Icon(Icons.skip_previous),
                              onPressed: progress.time != 0
                                  ? nowPlaying.skipPrevious
                                  : null),
                        ),
                        IconButton(
                            padding: EdgeInsets.all(12),
                            splashRadius: 24,
                            icon: AnimatedIcon(
                              progress: playStateController,
                              icon: AnimatedIcons.play_pause,
                            ),
                            disabledColor: Color.alphaBlend(
                                Theme.of(context).disabledColor,
                                Theme.of(context).colorScheme.surface),
                            color: Color.alphaBlend(
                                Theme.of(context).iconTheme.color,
                                Theme.of(context).colorScheme.surface),
                            onPressed: !nowPlaying.empty && !nowPlaying.ended
                                ? nowPlaying.togglePlay
                                : null),
                        IconButton(
                            padding: EdgeInsets.all(12),
                            splashRadius: 24,
                            icon: Icon(Icons.skip_next),
                            onPressed: !nowPlaying.empty && !nowPlaying.ended
                                ? nowPlaying.skipNext
                                : null)
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: provider.Consumer<Progress>(
                    builder: (context, progress, child) =>
                        buildLinearPercentIndicator(
                            context, progress.percent, !nowPlaying.playing),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  LinearPercentIndicator buildLinearPercentIndicator(
      BuildContext context, double percent, bool animate) {
    return LinearPercentIndicator(
      curve: Curves.fastOutSlowIn,
      animation: false,
      animationDuration: 300,
      animateFromLastPercent: false,
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
    @required this.animation,
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

  // Animation<double> scale;

  // double value;

  // double get scale => value * 3 - 2 > 0 ? value * 3 - 2 : 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // scale = Tween<double>(begin: 0, end: 1).animate(
    //   CurvedAnimation(
    //     parent: widget.animation,
    //     curve: Interval(
    //       2 / 3,
    //       1,
    //     ),
    //   ),
    // );

    // if (widget.animation != null) {
    //   value = widget.animation.value;
    //   widget.animation.addListener(() {
    //     if (mounted)
    //       setState(() {
    //         value = widget.animation.value;
    //       });
    //   });
    // } else {
    //   if (widget.isSmall)
    //     value = 0.0;
    //   else
    //     value = 1.0;
    // }
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
    return (end - start) * widget.animation.value + start;
  }

  double scale() {
    return widget.animation.value * 3 - 2 > 0
        ? widget.animation.value * 3 - 2
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) {
        final showFirst = !nowPlaying.inSet && !nowPlaying.inEnd;

        return AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) => Stack(
            children: [
              AnimatedOpacity(
                opacity: showFirst ? 1 : 0,
                duration: Duration(milliseconds: animationDuration),
                child: provider.Consumer<Progress>(
                  builder: (context, progress, child) =>
                      CircularPercentIndicator(
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
                    percent: !nowPlaying.inSet
                        ? progress.setPercent.toDouble()
                        : 0.0,
                    progressColor: Color.alphaBlend(
                        Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                        Theme.of(context).colorScheme.background),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(40),
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
                          size: Size.square(scale() * maxContainerWidth),
                          child: Opacity(
                            opacity: widget.animation.value,
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
                  builder: (context, progress, child) =>
                      CircularPercentIndicator(
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
                          size: Size.square(scale() * maxContainerWidth),
                          child: Opacity(
                            opacity: widget.animation.value,
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
                                        (nowPlaying.inSet &&
                                                nowPlaying.currentRep <=
                                                    nowPlaying.exercise.reps)
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
                                                color: Theme.of(context)
                                                    .accentColor,
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
          ),
        );
      },
    );
  }
}

class ExpandableSheet extends StatefulWidget {
  ExpandableSheet({
    Key key,
    this.child,
    @required this.sheet,
    this.initialHeight = 72,
    @required this.controller,
    @required this.showController,
    this.onDismiss,
    this.builder,
    this.detectGestures = true,
  })  : this.showHeight =
            Tween<double>(begin: 0, end: initialHeight).animate(showController),
        this.opacity = Tween<double>(begin: 0, end: 0.32).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0,
              0.5,
              curve: Curves.linear,
            ),
          ),
        ),
        super(key: key);

  final Widget child;
  final Widget sheet;
  final Widget Function(
          BuildContext context, AnimationController controller, Widget child)
      builder;
  final double initialHeight;
  final void Function() onDismiss;

  final AnimationController controller;
  final AnimationController showController;

  final Animation<double> showHeight;
  final Animation<double> opacity;

  final bool detectGestures;

  @override
  _ExpandableSheetState createState() => _ExpandableSheetState();
}

class _ExpandableSheetState extends State<ExpandableSheet> {
  bool fromStart = true;
  bool triedToDismiss = false;

  Animation<double> height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // showController =
    //     widget.showController ?? AnimationController(vsync: this, value: 1);

    // showHeight = Tween<double>(begin: 0, end: widget.initialHeight)
    //     .animate(widget.showController);

    // opacity = Tween<double>(begin: 0, end: 0.32).animate(
    //   CurvedAnimation(
    //     parent: widget.controller,
    //     curve: Interval(
    //       0,
    //       0.5,
    //       curve: Curves.linear,
    //     ),
    //   ),
    // );

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

    actualConstraints = BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width);

    deltaHeight = actualConstraints.maxHeight - actualConstraints.minHeight;
  }

  BoxConstraints actualConstraints;
  double deltaHeight;

  @override
  Widget build(BuildContext context) {
    height = Tween<double>(
      begin: widget.initialHeight,
      end: actualConstraints.maxHeight,
    ).animate(widget.controller);

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
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Positioned(
              top: 0,
              child: AnimatedBuilder(
                animation: widget.showController,
                builder: (context, child) => SizedBox(
                  height: actualConstraints.maxHeight - widget.showHeight.value,
                  width: actualConstraints.maxWidth,
                  child: widget.child,
                ),
              ),
            ),
            IgnorePointer(
              ignoring: widget.controller.isDismissed,
              child: SizedBox.expand(
                child: FadeTransition(
                  opacity: widget.opacity,
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
                  animation: widget.showController,
                  builder: (context, child) {
                    var bottom = (Tween<double>(begin: -1, end: 0)
                            .animate(widget.showController)
                            .value *
                        height.value);
                    return Positioned(
                      top: MediaQuery.of(context).size.height -
                          bottom -
                          height.value,
                      child: Opacity(
                        opacity: Tween<double>(begin: 0, end: 1)
                            .animate(
                              CurvedAnimation(
                                parent: widget.showController,
                                curve: Interval(0, 0.2),
                              ),
                            )
                            .value,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (widget.controller.isDismissed)
                        widget.controller.fling();
                    },
                    onVerticalDragUpdate: (details) {
                      if (widget.detectGestures) {
                        final newValue = widget.controller.value -
                            details.primaryDelta / deltaHeight;
                        if (!triedToDismiss && newValue >= 0 && newValue <= 1) {
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
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (widget.detectGestures) {
                        if (triedToDismiss) {
                          setState(() {
                            triedToDismiss = false;
                          });
                          if (widget.showController.value < 0.85) {
                            widget.showController.fling(velocity: -1).then((_) {
                              if (widget.onDismiss != null) widget.onDismiss();
                            });
                          } else {
                            widget.showController.fling();
                          }
                        }

                        final threshold = 2.0;
                        final velocity =
                            -details.velocity.pixelsPerSecond.dy / deltaHeight;

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
                          widget.controller.fling(velocity: fromStart ? 1 : -1);
                        else
                          widget.controller.fling(velocity: fromStart ? -1 : 1);
                      }
                    },
                    child: SizedBox(
                      height: height.value,
                      width: actualConstraints.maxWidth,
                      child: child,
                    ),
                  ),
                );
              },
              child: widget.sheet,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableBox extends StatefulWidget {
  ExpandableBox({
    Key key,
    this.child,
    @required this.maxHeight,
    @required this.minHeight,
    @required this.controller,
    Animation<double> height,
  })  : this.height = height ??
            Tween<double>(begin: minHeight, end: maxHeight).animate(controller),
        super(key: key) {
    // assert((minHeight != null && maxHeight != null) || height != null);
  }

  final Widget child;
  final double maxHeight;
  final double minHeight;
  final AnimationController controller;
  final Animation<double> height;

  @override
  _ExpandableBoxState createState() => _ExpandableBoxState();
}

class _ExpandableBoxState extends State<ExpandableBox> {
  bool fromStart = true;

  double get deltaHeight => widget.maxHeight - widget.minHeight;

  @override
  void initState() {
    super.initState();

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
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (widget.controller.isDismissed) widget.controller.fling();
        },
        onVerticalDragUpdate: (details) {
          final newValue =
              widget.controller.value - details.primaryDelta / deltaHeight;
          if (newValue >= 0 && newValue <= 1) {
            widget.controller.value = newValue;
          }
        },
        onVerticalDragEnd: (details) {
          final threshold = 1.0;
          final velocity = -details.velocity.pixelsPerSecond.dy / deltaHeight;

          final velocityCheck = velocity.abs() >= threshold;
          final positionCheck = (fromStart && widget.controller.value > 0.5) ||
              (!fromStart && widget.controller.value < 0.8);

          print('Velocity is high enough: ' + velocityCheck.toString());
          print('Position is high enough: ' + positionCheck.toString());
          print('Coming from start: ' + fromStart.toString());

          if (velocityCheck)
            widget.controller.fling(velocity: velocity);
          else if (positionCheck)
            widget.controller.fling(velocity: fromStart ? 1 : -1);
          else
            widget.controller.fling(velocity: fromStart ? -1 : 1);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.height.value,
            minHeight: widget.minHeight,
          ),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
