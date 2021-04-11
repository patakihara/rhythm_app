import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'providers.dart';
import 'widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'classes.dart';
import 'package:flutter/foundation.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'exercise_page.dart';
import 'home_page.dart';

class PlanPage extends StatefulWidget {
  final Plan plan;

  const PlanPage({Key key, this.plan}) : super(key: key);
  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> with TickerProviderStateMixin {
  bool _editing;
  bool _changed;
  bool _deleting;

  bool get editing => _editing;
  bool get changed => _changed;
  bool get deleting => _deleting;

  set editing(bool value) {
    setState(() {
      _editing = value;
    });
    if (value)
      editStateController.fling();
    else
      editStateController.fling(velocity: -1);
  }

  AnimationController editStateController;
  Animation<double> fabSize;

  AnimationController playStateController;

  Plan plan;

  AnimationController appBarHeightController;
  ScrollController scrollController = ScrollController();
  double lastAppBarHeightValue = 0;

  String name;
  List<String> exerciseNames;

  bool fromCard;
  // bool changed = false;
  bool reorderable = false;

  bool _bottomVisibleAtStart;
  bool _bottomVisibleNow;

  Key lastItemKey;

  bool _checkedInitialVisibility = false;
  bool _checkedVisibility = false;

  bool get bottomVisibleAtStart {
    VisibilityDetectorController.instance.updateInterval =
        Duration(microseconds: 0);
    if (!_checkedInitialVisibility) {
      setState(() {
        if (VisibilityDetectorController.instance
                .widgetBoundsFor(lastItemKey) !=
            null)
          _bottomVisibleAtStart = true;
        else
          _bottomVisibleAtStart = false;
        _checkedInitialVisibility = true;
      });
    }
    return _bottomVisibleAtStart;
  }

  bool get bottomVisibleNow {
    VisibilityDetectorController.instance.updateInterval =
        Duration(microseconds: 0);
    setState(() {
      if (!_checkedVisibility) _bottomVisibleNow = bottomVisibleAtStart;
    });
    return _bottomVisibleNow;
  }

  double extent = 0;
  // double maxExtent;
  bool scrollable = false;
  bool atTopOfList = true;

  double get maxExtent {
    var height1 = MediaQuery.of(context).size.height / 2 -
        56 -
        MediaQuery.of(context).viewPadding.top;
    var height2 = MediaQuery.of(context).size.width -
        56 -
        MediaQuery.of(context).viewPadding.top;
    var initialHeight = height1 > height2 ? height2 : height1;
    var minHeight = 96;
    var x = initialHeight - minHeight;
    // if (exercises.length < 5) {
    //   x = x - (5 - exercises.length) * 56;
    // }
    return x;
  }

  // bool showPlayCard = false;

  List<Exercise> get exercises {
    List<Exercise> res = <Exercise>[];
    for (var i = 0; i < exerciseNames.length; i++) {
      res.add(provider.Provider.of<Library>(context, listen: false)
          .exercisesMap[exerciseNames[i]]);
    }
    return res;
  }

  List<Key> keys = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    plan = widget.plan;
    _deleting = false;
    _editing = (widget.plan == null);
    if (editing)
      _changed = true;
    else
      _changed = false;
    if (plan != null) {
      name = plan.name;
      exerciseNames = plan.exerciseNames.sublist(0);
      for (var i = 0; i < exerciseNames.length; i++) {
        keys.add(Key(exerciseNames[i] + DateTime.now().toString()));
      }
      fromCard = true;
    } else {
      exerciseNames = <String>[];
      fromCard = false;
    }

    appBarHeightController = AnimationController(vsync: this, value: 0.0);
    appBarHeightController.addListener(() => animateExtent());
    scrollController.addListener(() {
      setState(() {
        if (scrollController.offset > 0)
          atTopOfList = false;
        else
          atTopOfList = true;
      });
    });

    editStateController = AnimationController(vsync: this);
    fabSize = Tween<double>(begin: 56, end: 0).animate(
      CurvedAnimation(
        parent: editStateController,
        curve: Curves.ease,
      ),
    );

    playStateController = AnimationController(vsync: this);

    super.initState();
    if (widget.plan == null) appBarHeightController.fling();
  }

  void animateExtent() {
    // var initialHeight = MediaQuery.of(context).size.width -
    //     56 -
    //     MediaQuery.of(context).viewPadding.top;
    // var minHeight = 96;
    setState(() {
      extent = appBarHeightController.value * maxExtent;
      scrollable = appBarHeightController.value == 1;
      //print('scrollable: ' + scrollable.toString());
      //print('appBarHeightController value: ' +
      // appBarHeightController.value.toString());
      if (appBarHeightController.value == 0.0) {
        scrollController.animateTo(0,
            duration: provider.Provider.of<MenuProvider>(context, listen: false)
                .navBarTransitionDuration,
            curve: null);
        atTopOfList = true;
      }
    });
  }

  void updateChanged() {
    setState(() {
      if (plan != null) {
        _changed =
            !listEquals(exerciseNames, plan.exerciseNames) || name != plan.name;
      } else
        _changed = true;
    });
  }

  bool get valid {
    var counts = provider.Provider.of<Library>(context).planNameCounts;
    return (exerciseNames.isNotEmpty &&
        name != null &&
        name.isNotEmpty &&
        (counts[name] == null || (plan != null && counts[name] < 2)));
  }

  List<Widget> buildExerciseTiles(BuildContext context) {
    List<Widget> res = [];
    var nowPlaying = provider.Provider.of<NowPlaying>(context);
    for (var i = 0; i < exercises.length; i++) {
      bool currentlyPlaying() =>
          plan != null &&
          !nowPlaying.empty &&
          nowPlaying.plan.name == plan.name &&
          nowPlaying.exerciseIndex == i;
      bool willPlayLater() =>
          !nowPlaying.empty &&
          nowPlaying.plan.name == plan.name &&
          i > nowPlaying.exerciseIndex;
      bool hasPlayedBefore() =>
          !nowPlaying.empty &&
          nowPlaying.plan.name == plan.name &&
          i < nowPlaying.exerciseIndex;
      res.add(
        editing
            ? DismissibleExerciseTile(
                key: keys[i],
                exercise: exercises[i],
                selected: currentlyPlaying() && !editing,
                leading: SizedBox(
                  width: 72.0 - 32.0,
                ),
                onTap: () {},
                onDismissed: (_) {
                  setState(() {
                    exerciseNames.removeAt(i);
                    keys.removeAt(i);
                    updateChanged();
                  });
                },
              )
            : ExerciseTile(
                key: keys[i],
                exercise: exercises[i],
                selected: currentlyPlaying() && !editing,
                leading: SizedBox(
                  width: 72.0 - 32.0,
                ),
                onTap: () {
                  if (!editing) {
                    if (nowPlaying.empty || nowPlaying.plan.name != plan.name) {
                      nowPlaying.changePlan(plan);
                    }
                    if (!currentlyPlaying()) {
                      if (willPlayLater())
                        while (!currentlyPlaying()) nowPlaying.skipForward();
                      else if (hasPlayedBefore())
                        while (!currentlyPlaying()) nowPlaying.skipBackward();
                      nowPlaying.play();
                    }
                  }
                },
              ),
      );
    }
    if (editing) {
      res.add(Material(
        key: Key('add new'),
        type: MaterialType.card,
        elevation: 2,
        child: ListTile(
            contentPadding: res.isEmpty
                ? EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 0)
                : null,
            dense: true,
            title: DropdownButton<String>(
              value: null,
              // isDense: true,
              icon: Icon(Icons.arrow_drop_down),
              underline: Container(),
              hint: Text(
                'Add an exercise',
                style: Theme.of(context).textTheme.bodyText2.apply(
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                    fontWeightDelta: 1),
              ),
              style: Theme.of(context).textTheme.bodyText2.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeightDelta: 1),
              onChanged: (value) {
                if (value != 'New exercise')
                  setState(() {
                    exerciseNames.add(value);
                    keys.add(Key(value + DateTime.now().toString()));
                    updateChanged();
                  });
                else {
                  // provider.Provider.of<MenuProvider>(context, listen: false)
                  //     .showNavBar = false;
                  Navigator.push(
                      context,
                      Methods.slideUpRoute(ExercisePage(
                        fromPlanPage: true,
                      ))).then((value) {
                    provider.Provider.of<MenuProvider>(context, listen: false)
                        .inExercisePage = false;
                    if (value != null)
                      setState(() {
                        exerciseNames.add(value);
                        keys.add(Key(value + DateTime.now().toString()));
                        updateChanged();
                      });
                  });
                  Timer(
                      provider.Provider.of<MenuProvider>(context, listen: false)
                          .navBarTransitionWait, () {
                    // provider.Provider.of<MenuProvider>(context, listen: false)
                    //     .showNavBar = true;
                  });
                  provider.Provider.of<MenuProvider>(context, listen: false)
                      .inExercisePage = true;
                }
              },
              items: () {
                var items = provider.Provider.of<Library>(context)
                    .exerciseNames
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList();
                items.add(DropdownMenuItem<String>(
                    child: Text('New exercise',
                        style: Theme.of(context).textTheme.subtitle2.apply(
                            color: Theme.of(context).colorScheme.secondary)),
                    value: 'New exercise'));
                return items;
              }(),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.add),
            )),
      ));
    } else {
      res.add(Container(key: Key('add new')));
    }

    res.add(SizedBox(
      height: 72,
      key: Key('second to las'),
    ));

    res.add(SizedBox(height: 1, key: Key('last item')));

    var lastWidget = VisibilityDetector(
      key: res.last.key,
      onVisibilityChanged: (info) {
        setState(() {
          if (info.visibleFraction > 0)
            _bottomVisibleNow = true;
          else
            _bottomVisibleNow = false;
        });
      },
      child: res.last,
    );
    res.last = lastWidget;

    setState(() => lastItemKey = res.last.key);

    return res;
  }

  void _reorderExercises(oldIndex, newIndex) {
    if (newIndex > oldIndex)
      newIndex = newIndex - 1;
    else
      newIndex = newIndex;
    var aux = exerciseNames[oldIndex];
    exerciseNames[oldIndex] = exerciseNames[newIndex];
    exerciseNames[newIndex] = aux;
    var aux2 = keys[oldIndex];
    keys[oldIndex] = keys[newIndex];
    keys[newIndex] = aux2;
    updateChanged();
  }

  Widget buildHeader() {
    return exerciseNames.isNotEmpty
        ? Material(
            type: MaterialType.card,
            elevation: atTopOfList && !editing ? 1 : 2,
            shadowColor:
                atTopOfList && !editing ? Colors.transparent : Colors.black,
            clipBehavior: atTopOfList && !editing ? Clip.hardEdge : Clip.none,
            child: ListTile(
              dense: false,
              title: Text('Exercises',
                  style: Theme.of(context).textTheme.bodyText1.apply(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.6))),
              leading: SizedBox(
                width: 72.0 - 32.0,
              ),
            ),
          )
        : SizedBox(height: 0);
  }

  void discardChanges() {
    name = plan.name;
    exerciseNames = plan.exerciseNames.sublist(0);
  }

  Future<bool> onBackPressed() async {
    bool close = false;

    if ((plan == null || !editing) && !deleting) {
      close = true;
    } else if (deleting) {
      await showDialog<bool>(
          context: context,
          builder: (_) {
            return DeleteDialog(context: context);
          }).then((delete) {
        setState(() {
          _deleting = delete ?? false;
        });
      });
      close = deleting;
      if (deleting) context.read<Library>().removePlan(plan);
    } else if (changed) {
      await showDialog<bool>(
          context: context,
          builder: (_) {
            return DiscardChangesDialog(context: context);
          }).then((discard) {
        if (discard) editing = false;
        setState(() {
          discardChanges();
        });
      });
      close = false;
    } else {
      editing = false;

      close = false;
    }

    if (close) closePage();
    return false;
  }

  void closePage() {
    // context.read<MenuProvider>().showNavBar = true;
    context.read<MenuProvider>().inPlanPage = false;
    context.read<MenuProvider>().openPlan = null;
  }

  @override
  Widget build(BuildContext context) {
    appBarHeightController.duration =
        provider.Provider.of<MenuProvider>(context).navBarTransitionDuration;

    var height1 = MediaQuery.of(context).size.height / 2 -
        56 -
        MediaQuery.of(context).viewPadding.top;
    var height2 = MediaQuery.of(context).size.width -
        56 -
        MediaQuery.of(context).viewPadding.top;
    var initialHeight = height1 > height2 ? height2 : height1;

    if (context.watch<NowPlaying>().playing &&
        playStateController.isDismissed) {
      playStateController.fling();
    } else if (!context.watch<NowPlaying>().playing &&
        playStateController.isCompleted) {
      playStateController.fling(velocity: -1);
    }

    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            buildAppBarBackground(context, initialHeight + 10),
            // buildBodyBackground(context, initialHeight),
            Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                brightness: Brightness.dark,
                backgroundColor: Colors.transparent,
                textTheme: Theme.of(context).textTheme,
                actionsIconTheme: Theme.of(context).primaryIconTheme,
                iconTheme: Theme.of(context).primaryIconTheme,
                // actions: [
                //   IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                // ],
                leading: IconButton(
                    icon: plan == null || editing
                        ? Icon(Icons.close)
                        : Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context)),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(initialHeight - extent),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 72, bottom: 8),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 72 * 3,
                              child: provider.Consumer<Library>(
                                builder: (context, library, child) => Theme(
                                  data: ThemeData(brightness: Brightness.dark),
                                  child: IgnorePointer(
                                    ignoring: !editing,
                                    child: TextFormField(
                                      autofocus: editing &&
                                          plan == null &&
                                          (name == null || name.isEmpty),
                                      readOnly: !editing,
                                      initialValue: name,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      autocorrect: true,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        var counts =
                                            provider.Provider.of<Library>(
                                                    context)
                                                .planNameCounts;
                                        if (value.isEmpty) {
                                          return 'You have to enter a name.';
                                        } else if (counts[name] == null) {
                                          return null;
                                        } else if (plan == null) {
                                          return 'Plan already exists.';
                                        } else if (counts[name] > 1) {
                                          return 'Plan already exists.';
                                        } else if (name != plan.name) {
                                          return 'Plan already exists.';
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                          // labelText: 'Name',
                                          hintText: 'New plan',
                                          border: InputBorder.none),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .apply(
                                              color: Colors.white,
                                              fontWeightDelta: 1),
                                      onChanged: (newValue) {
                                        setState(() {
                                          name = newValue;
                                          updateChanged();
                                        });
                                        //print(name);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: Listener(
                onPointerMove: (details) {
                  //print('updated');
                  if (!editing &&
                      (extent - details.delta.dy) <= maxExtent &&
                      extent - details.delta.dy >= 0 &&
                      details.delta.dy.abs() > details.delta.dx.abs() &&
                      ((details.delta.dy < 0) ||
                          (details.delta.dy > 0 && atTopOfList))) {
                    setState(() {
                      appBarHeightController.value =
                          appBarHeightController.value -
                              details.delta.dy / maxExtent;
                      if (appBarHeightController.value >= 0.95)
                        appBarHeightController.fling();
                    });
                  }
                  if (!scrollable ||
                      (atTopOfList && bottomVisibleNow && !editing)) {
                    scrollController.jumpTo(0);
                  } else if (!editing &&
                      scrollController.offset - details.delta.dy >= -0.001) {
                    setState(() {
                      scrollController
                          .jumpTo(scrollController.offset - details.delta.dy);
                      if (scrollController.offset - details.delta.dy <= 0)
                        atTopOfList = true;
                    });
                  }
                  // else if (details.delta.dy <= 0 && bottomVisibleNow) {
                  //   scrollController.jumpTo(scrollController.offset);
                  // } else if (!editing &&
                  //     scrollController.offset - details.delta.dy >= -0.01) {
                  //   setState(() {
                  //     scrollController
                  //         .jumpTo(scrollController.offset - details.delta.dy);
                  //     if (scrollController.offset - details.delta.dy <= 0)
                  //       atTopOfList = true;
                  //   });
                  // }
                  //print('scrollable: ' + scrollable.toString());
                  // if (details.delta.dy < 0)
                  //print('moving up');
                  // else
                  //print('moving down');
                  //print('All items visible:' + bottomVisibleNow.toString());
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    Expanded(
                      child: editing
                          ? ReorderableListView(
                              // header: buildHeader(),
                              scrollController: scrollController,
                              onReorder: (oldIndex, newIndex) {
                                print('old index: ' + oldIndex.toString());
                                print('new index: ' + newIndex.toString());
                                setState(() =>
                                    _reorderExercises(oldIndex, newIndex));
                              },
                              children: buildExerciseTiles(context))
                          : ListView(
                              controller: scrollController,
                              clipBehavior: Clip.hardEdge,
                              // physics:
                              //     scrollable ? null : NeverScrollableScrollPhysics(),
                              children: buildExerciseTiles(context),
                            ),
                    ),
                    buildHeader(),
                  ],
                ),
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Color.alphaBlend(
                          Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.2),
                          Theme.of(context).colorScheme.background),
                      child: Icon(editing ? Icons.save : Icons.edit,
                          color: (changed && valid) || !editing
                              ? Theme.of(context).iconTheme.color
                              : Theme.of(context)
                                  .iconTheme
                                  .color
                                  .withOpacity(.38)),
                      onPressed: (changed && valid) || !editing
                          ? () {
                              FocusScope.of(context).unfocus();
                              editing = !editing;
                              if (!editing) {
                                setState(() {
                                  _changed = false;
                                });
                                appBarHeightController.fling(velocity: -1);
                                appBarHeightController.addListener(flingBack);
                                _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(content: Text('Plan saved')));
                                var names = exerciseNames;
                                if (plan == null) {
                                  plan = Plan.fromList(name, names);
                                  provider.Provider.of<Library>(context,
                                          listen: false)
                                      .addPlan(plan);
                                } else {
                                  var newPlan = Plan.fromList(name, names);
                                  provider.Provider.of<Library>(context,
                                          listen: false)
                                      .swapPlan(plan, newPlan);
                                  plan = newPlan;
                                }
                              } else {
                                lastAppBarHeightValue =
                                    appBarHeightController.value;
                                appBarHeightController.fling(velocity: 1);
                              }
                            }
                          : null,
                      mini: true,
                    ),
                    provider.Consumer<NowPlaying>(
                      builder: (context, nowPlaying, child) => AnimatedBuilder(
                        animation: editStateController,
                        builder: (context, child) => Padding(
                          padding:
                              EdgeInsets.all((56 - fabSize.value.abs()) / 2),
                          child: Material(
                            shape: CircleBorder(),
                            elevation: 8,
                            child: ClipOval(
                              child: SizedOverflowBox(
                                size: Size.square(fabSize.value.abs()),
                                child: FloatingActionButton(
                                  heroTag: 'planBigFab',
                                  child: ClipOval(
                                    child: SizedOverflowBox(
                                      size: Size.square(
                                        (fabSize.value.abs() - 32).clamp(
                                          0.0,
                                          24.0,
                                        ),
                                      ),
                                      child: AnimatedIcon(
                                        progress: playStateController,
                                        icon: AnimatedIcons.play_pause,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (nowPlaying.empty ||
                                        nowPlaying.plan.name != plan.name)
                                      nowPlaying.changePlan(plan);
                                    else
                                      nowPlaying.togglePlay();
                                  },
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
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            ),
          ],
        ),
        // bottomNavigationBar: AnimatedPlayCard(),
        // bottomNavigationBar: AnimatedBottomBar(
        //   child: Column(children: [AnimatedPlayCard(progressOnTop: true)]),
        // ),
        // bottomNavigationBar: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     AnimatedPlayCard(),
        //     buildBottomNavigationBar(context),
        //   ],
        // ),
      ),
    );
  }

  void flingBack() {
    if (appBarHeightController.value <= lastAppBarHeightValue) {
      appBarHeightController.stop();
      appBarHeightController.removeListener(flingBack);
    }
  }

  Widget buildAppBarBackground(BuildContext context, double initialHeight) {
    return IgnorePointer(
      child: Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          leadingWidth: 0,
          elevation: 4,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textTheme: Theme.of(context).textTheme,
          actionsIconTheme: Theme.of(context).primaryIconTheme,
          iconTheme: Theme.of(context).primaryIconTheme,
          // actions: [
          //   IconButton(icon: Icon(Icons.edit), onPressed: () {}),
          // ],
          automaticallyImplyLeading: false,
          leading: null,
          actions: [
            IconButton(
              icon: AnimatedBuilder(
                animation: editStateController,
                builder: (context, child) => Opacity(
                  opacity: editStateController.value,
                  child: Icon(
                    Icons.delete,
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _deleting = true;
                });
                Navigator.maybePop(context, plan != null ? plan.name : null);
              },
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(initialHeight - extent + 40),
            child: Padding(
              padding: const EdgeInsets.only(left: 72, bottom: 8),
            ),
          ),
          flexibleSpace: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: FractionalOffset.bottomCenter,
              //       end: FractionalOffset.topCenter,
              //       colors: [
              //         Colors.black.withAlpha(80),
              //         Colors.black.withAlpha(30),
              //         Colors.black.withAlpha(0),
              //         Colors.black.withAlpha(0)
              //       ],
              //     ),
              //   ),
              Opacity(
                opacity: (1 - appBarHeightController.value) * 0.8 + 0.2,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Image.asset(
                      'assets/images/jpeg/image' +
                          (plan != null
                              ? (context
                                          .read<Library>()
                                          .planNames
                                          .indexOf(plan.name) +
                                      1)
                                  .toString()
                              : (context.read<Library>().planNames.length + 1)
                                  .toString()) +
                          '.jpeg',
                      height: initialHeight - extent + 56,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      margin: EdgeInsets.all(0),
                      height: initialHeight - extent + 56,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0),
                        gradient: LinearGradient(
                          begin: FractionalOffset.bottomCenter,
                          end: FractionalOffset.topCenter,
                          colors: [
                            Colors.black.withOpacity(.90),
                            Colors.black.withOpacity(.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                elevation: 8,
                color: Colors.transparent,
                // shadowColor: Colors.red,
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  // thickness: 1,
                  color: Colors.transparent,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    VisibilityDetectorController.instance.forget(lastItemKey);
    super.dispose();
  }
}
