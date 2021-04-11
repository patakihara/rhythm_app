import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rubber/rubber.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart' as provider;
import 'classes.dart';
import 'widgets.dart';
import 'providers.dart';
import 'plan_page.dart';
import 'exercise_page.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'play_menu.dart';

// import 'package:sounds/sounds.dart';

// final Plan todaysPlan =
//     Plan('Upper body 1', [Exercise(), Exercise(name: 'Biceps')]);

class Methods {
  static Route slideUpRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  static List<String> labels = ['Home', 'Timers', 'Calendar'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      provider.Provider.of<MenuProvider>(context, listen: false).menu =
          Menu.values[index];
      provider.Provider.of<MenuProvider>(context, listen: false)
          .appBarElevated = false;
    });
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // return PlayMenu();

    return provider.Consumer<MenuProvider>(
      builder: (context, menuProvider, child) => Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text('Rhythm')),
              ListTile(
                title: Text('Settings'),
                leading: Icon(Icons.settings),
                onTap: () {},
              ),
              AboutListTile(
                icon: Icon(Icons.info),
                applicationName: 'Rhythm',
                aboutBoxChildren: [Text('Gym timer and metronome.')],
              ),
              Divider(),
              ListTile(
                title: Text('Change theme'),
                leading: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.brightness_7
                      : Icons.brightness_4,
                ),
                onTap: () {
                  context.read<MenuProvider>().flipTheme();
                },
              ),
            ],
          ),
        ),
        body: PlayMenu(
          child: Container(
            child: PageTransitionSwitcher(
              duration: menuProvider.pageTransitionDuration,
              transitionBuilder: (Widget child, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: (!menuProvider.inPlanPage && !menuProvider.inExercisePage)
                  ? Container(
                      key: ValueKey('homePage'),
                      child: Scaffold(
                        key: ValueKey('scaffoldHomePage'), //scaffoldKey,
                        appBar: PreferredSize(
                          preferredSize: Size.fromHeight(56),
                          child: Material(
                            animationDuration:
                                menuProvider.navBarTransitionDuration,
                            color: menuProvider.appBarElevated
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(1))
                                : Theme.of(context).colorScheme.background,
                            elevation: menuProvider.appBarElevated &&
                                    menuProvider.menu != Menu.timers
                                ? 4
                                : 0,
                            child: AppBar(
                              leading: IconButton(
                                icon: Icon(Icons.menu),
                                onPressed: () {
                                  scaffoldKey.currentState.openDrawer();
                                },
                              ),
                              primary: true,
                              centerTitle: false,
                              title: Text(
                                'Rhythm',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .apply(
                                        fontWeightDelta: 3,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)
                                    .copyWith(letterSpacing: -1.0),
                              ),
                              iconTheme: Theme.of(context).iconTheme.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .color),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ),
                        body: Container(
                          child: PageTransitionSwitcher(
                            duration: menuProvider.pageTransitionDuration,
                            transitionBuilder: (Widget child,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) {
                              return FadeThroughTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                child: child,
                              );
                            },
                            child: menuProvider.menuWidget,
                          ),
                        ),
                      ),
                    )
                  : menuProvider.inPlanPage
                      ? Container(
                          key: ValueKey('planPage'),
                          child: PlanPage(
                            plan: menuProvider.openPlan,
                          ),
                        )
                      : Container(
                          key: ValueKey('exercisePage'),
                          child: ExercisePage(
                            exercise: menuProvider.openExercise,
                          ),
                        ),
            ),
          ),
        ),
        // bottomNavigationBar: AnimatedPlayCard(),
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

  Widget buildBottomNavigationBar(BuildContext context) {
    return AnimatedContainer(
      duration:
          provider.Provider.of<MenuProvider>(context).navBarTransitionDuration,
      height: provider.Provider.of<MenuProvider>(context).navBarBarHeight,
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        controller: ScrollController(),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: labels[0]),
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: labels[1]),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: labels[2]),
          ],
          showUnselectedLabels: false,
          selectedFontSize: 13,
        ),
      ),
    );
  }
}

class CalendarMenu extends StatefulWidget {
  const CalendarMenu({
    Key key,
  }) : super(key: key);

  @override
  _CalendarMenuState createState() => _CalendarMenuState();
}

class _CalendarMenuState extends State<CalendarMenu> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    controller.addListener(() {
      print('Calendar scroll controller updated');
      if (controller.offset != 0)
        provider.Provider.of<MenuProvider>(context, listen: false)
            .appBarElevated = true;
      else
        provider.Provider.of<MenuProvider>(context, listen: false)
            .appBarElevated = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('calendar'),
      child: Card(),
    );
  }
}

class TimersMenu extends StatefulWidget {
  const TimersMenu({
    Key key,
  }) : super(key: key);

  @override
  _TimersMenuState createState() => _TimersMenuState();
}

class _TimersMenuState extends State<TimersMenu> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  TabController tabController;

  double _lastOffset = 0;

  bool showAllPlans = true;

  Animation<double> fabSize;
  Animation<double> fabOpacity;

  @override
  void initState() {
    var menuProvider =
        provider.Provider.of<MenuProvider>(context, listen: false);
    scrollController.addListener(() {
      print('Timers scroll controller updated');
      if (scrollController.offset != 0)
        menuProvider.appBarElevated = true;
      else
        menuProvider.appBarElevated = false;
      if (scrollController.offset - _lastOffset > 56) {
        // menuProvider.navBarBarHeight = 0;
        _lastOffset = scrollController.offset;
      } else if (scrollController.offset - _lastOffset < -56) {
        // menuProvider.navBarBarHeight = 56;
        _lastOffset = scrollController.offset;
      }
    });
    tabController = TabController(length: 2, vsync: this);
    tabController.index = (menuProvider.tabMenu == TabMenu.plans) ? 0 : 1;

    tabController.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        menuProvider.appBarElevated = false;
      }
    });

    tabController.addListener(() {
      // if ((tabController.index == 0 && menuProvider.tabMenu != TabMenu.plans) ||
      //     (tabController.index == 1 &&
      //         menuProvider.tabMenu != TabMenu.exercises)) {
      //   menuProvider.appBarElevated = false;
      // }

      if (tabController.index == 0) {
        menuProvider.tabMenu = TabMenu.plans;
      } else {
        menuProvider.tabMenu = TabMenu.exercises;
      }

      if ((tabController.animation.value == 0.0 ||
              tabController.animation.value == 1.0) &&
          tabController.previousIndex.toDouble() !=
              tabController.animation.value) {
        menuProvider.appBarElevated = false;
      }

      // if (tabController.indexIsChanging)
      //

      // print('offset is: ' + tabController.offset.toString());
      // if (tabController.offset.abs() < 0.5) {
      //   menuProvider.appBarElevated = false;
      // }
    });

    fabSize = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 56, end: 0).chain(
            CurveTween(curve: Curves.ease),
          ),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(0),
          weight: 20.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 56).chain(
            CurveTween(curve: Curves.ease),
          ),
          weight: 40.0,
        ),
      ],
    ).animate(tabController.animation);

    fabOpacity = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: tabController.animation,
        curve: Curves.easeInOut,
      ),
    );

    super.initState();
  }

  List<Widget> buildExericseTiles(BuildContext context,
      List<Exercise> exercises, Future<void> Function(int) onTap) {
    // provider.Provider.of<Library>(context).fixKeys();
    // var exercises = provider.Provider.of<Library>(context).exercises;
    List<Widget> res = [];
    for (var i = 0; i < exercises.length; i++)
      res.add(AnimatedExerciseTile(
          key: Key(exercises[i].key),
          exercise: exercises[i],
          onTap: () async {
            await onTap(i);
            return;
          }));
    return res;
  }

  List<Widget> buildPlanCards(BuildContext context, List<Plan> plans,
      double side, double spacing, Future<void> Function(int) onTap) {
    // provider.Provider.of<Library>(context).fixOrphans();
    // provider.Provider.of<Library>(context).fixDeadChildren();
    List<Widget> res = [];
    for (var i = 0; i < plans.length; i++) {
      res.add(PlanCard(
        key: Key(plans[i].key),
        plan: plans[i],
        width: side,
        height: side,
        image: 'assets/images/jpeg/image' + (i + 1).toString() + '.jpeg',
        onTap: () async {
          await onTap(i);
          return;
        },
      ));
      // res.add(SizedBox(width: spacing));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: provider.Consumer<MenuProvider>(
            builder: (context, menuProvider, child) => Material(
                animationDuration: menuProvider.navBarTransitionDuration,
                color: menuProvider.appBarElevated
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Theme.of(context).colorScheme.surface.withOpacity(1))
                    : Theme.of(context).colorScheme.background,
                elevation: menuProvider.appBarElevated ? 4 : 0,
                child: TabBar(
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                    indicatorColor: Theme.of(context).colorScheme.onSurface,
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.only(bottom: 8),
                    indicatorPadding: EdgeInsets.only(bottom: 12, top: 12),
                    labelStyle: Theme.of(context).textTheme.button.copyWith(
                        fontFamily:
                            Theme.of(context).textTheme.caption.fontFamily),
                    tabs: [Tab(text: 'Plans'), Tab(text: 'Exercises')])),
          )),
      body: TabBarView(
        controller: tabController,
        children: [
          Container(
            key: Key('plans'),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: ListView(
                  physics: ClampingScrollPhysics(),
                  clipBehavior: Clip.none,
                  controller: scrollController,
                  children: [
                    SizedBox(height: 24),
                    provider.Consumer<Library>(
                        builder: (context, library, child) {
                      var spacing = 8.0;
                      var side = (MediaQuery.of(context).size.width -
                              16.0 * 2 -
                              spacing) /
                          2;
                      return library.plans.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('No training plans',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .apply(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontWeightDelta: -1)),
                            )
                          : provider.Consumer2<NowPlaying, MenuProvider>(
                              builder:
                                  (context, nowPlaying, menuProvider, child) =>
                                      GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                clipBehavior: Clip.hardEdge,
                                primary: false,
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                crossAxisCount: 2,
                                children: buildPlanCards(
                                    context, library.plans, side, spacing,
                                    (index) async {
                                  print('Animating to item');
                                  var top = 24 +
                                      ((index / 2).floor()) * side +
                                      ((index / 2).floor() - 1) * spacing;
                                  var bottom =
                                      ((index / 2).floor() + 1) * side +
                                          ((index / 2).floor() - 1) * spacing;
                                  var deltaTop = scrollController.offset - top;
                                  var viewHeight =
                                      MediaQuery.of(context).size.height -
                                          56 - // appbar
                                          48 - // tab bar
                                          24 * 2 - // padding ??
                                          menuProvider
                                              .navBarBarHeight - // navBar
                                          (!nowPlaying.empty
                                              ? 56 + 20
                                              : 0) - // playCard
                                          MediaQuery.of(context)
                                              .viewPadding
                                              .top - //status bar
                                          24 - // FAB spacing
                                          (index % 2 == 1 ? 56 : 0) // FAB
                                      ;
                                  var deltaBottom =
                                      (bottom - scrollController.offset) -
                                          viewHeight;
                                  print(
                                      'Overflow is: ' + deltaBottom.toString());
                                  print('Total height is: ' +
                                      MediaQuery.of(context)
                                          .size
                                          .height
                                          .toString());
                                  if (top < scrollController.offset)
                                    await scrollController.animateTo(top,
                                        duration: Duration(
                                            milliseconds:
                                                (100 * deltaTop / 200).round()),
                                        curve: Curves.fastOutSlowIn);
                                  else if (deltaBottom > 0) {
                                    await scrollController.animateTo(
                                        scrollController.offset +
                                            deltaBottom +
                                            8,
                                        duration: Duration(
                                            milliseconds:
                                                (100 * (deltaBottom + 8) / 200)
                                                    .round()),
                                        curve: Curves.fastOutSlowIn);
                                  }
                                }),
                              ),
                            );
                    }),
                    SizedBox(height: MediaQuery.of(context).size.height / 3)
                  ]),
            ),
          ),
          Container(
            key: Key('exercises'),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: ListView(
                  physics: ClampingScrollPhysics(),
                  clipBehavior: Clip.none,
                  controller: scrollController,
                  children: [
                    SizedBox(height: 24),
                    provider.Consumer<Library>(
                      builder: (context, library, child) => library
                              .exercises.isNotEmpty
                          ? Container(
                              height: library.exercises.length * 72.0,
                              child:
                                  provider.Consumer2<NowPlaying, MenuProvider>(
                                builder: (context, nowPlaying, menuProvider,
                                        child) =>
                                    ListView(
                                        physics: ClampingScrollPhysics(),
                                        clipBehavior: Clip.none,
                                        children: buildExericseTiles(
                                            context, library.exercises,
                                            (index) async {
                                          print('Animating to item');
                                          var top = 24 + index * 72.0;
                                          var bottom = top + 72.0;
                                          var deltaTop =
                                              scrollController.offset - top;
                                          var viewHeight =
                                              MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  56 - // appbar
                                                  48 - // tab bar
                                                  24 * 2 - // padding ??
                                                  menuProvider
                                                      .navBarBarHeight - // navBar
                                                  (!nowPlaying.empty
                                                      ? 56 + 20
                                                      : 0) - // playCard
                                                  MediaQuery.of(context)
                                                      .viewPadding
                                                      .top - //status bar
                                                  24 - // FAB spacing
                                                  56 // FAB
                                              ;
                                          var deltaBottom = (bottom -
                                                  scrollController.offset) -
                                              viewHeight;
                                          if (top < scrollController.offset)
                                            await scrollController.animateTo(
                                                top,
                                                duration: Duration(
                                                    milliseconds:
                                                        (100 * deltaTop / 200)
                                                            .round()),
                                                curve: Curves.fastOutSlowIn);
                                          else if (deltaBottom > 0) {
                                            await scrollController.animateTo(
                                                scrollController.offset +
                                                    deltaBottom +
                                                    8,
                                                duration: Duration(
                                                    milliseconds: (100 *
                                                            (deltaBottom + 8) /
                                                            200)
                                                        .round()),
                                                curve: Curves.fastOutSlowIn);
                                          }
                                        })),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('No exercises',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .apply(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontWeightDelta: -1)),
                            ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 3)
                  ]),
            ),
          ),
        ],
      ),
      floatingActionButton: provider.Consumer<MenuProvider>(
        builder: (context, menuProvider, child) => AnimatedBuilder(
          animation: tabController.animation,
          builder: (context, child) => Padding(
            padding: EdgeInsets.all((56 - fabSize.value.abs()) / 2),
            child: Material(
              shape: CircleBorder(),
              elevation: 8,
              child: ClipOval(
                child: SizedOverflowBox(
                  size: Size.square(fabSize.value.abs()),
                  child: FloatingActionButton(
                    heroTag: menuProvider.tabMenu,
                    child: ClipOval(
                      child: SizedOverflowBox(
                        size: Size.square(
                          (fabSize.value.abs() - 32).clamp(
                            0.0,
                            24.0,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (menuProvider.tabMenu == TabMenu.plans) {
                        menuProvider.inPlanPage = true;
                      } else {
                        menuProvider.inExercisePage = true;
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeMenu extends StatefulWidget {
  const HomeMenu({
    Key key,
  }) : super(key: key);

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  final ScrollController controller = ScrollController();

  double _lastOffset = 0;

  @override
  void initState() {
    var menuProvider =
        provider.Provider.of<MenuProvider>(context, listen: false);
    controller.addListener(() {
      print('Home scroll controller updated');
      if (controller.offset != 0)
        menuProvider.appBarElevated = true;
      else
        menuProvider.appBarElevated = false;
      if (controller.offset - _lastOffset > 56) {
        // menuProvider.navBarBarHeight = 0;
        _lastOffset = controller.offset;
      } else if (controller.offset - _lastOffset < -56) {
        // menuProvider.navBarBarHeight = 56;
        _lastOffset = controller.offset;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('home'),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: ListView(
          controller: controller,
          clipBehavior: Clip.none,
          children: [
            SizedBox(height: 0),
            ListTitle(
              context: context,
              title: 'Today',
              button: 'Edit',
              subtitle: DateFormat('EEEE, MMMM d').format(DateTime.now()),
            ),
            provider.Consumer<Library>(builder: (context, library, child) {
              var spacing = 8.0;
              var side =
                  (MediaQuery.of(context).size.width - 16.0 * 2 - spacing) / 2;
              return library.plans.isNotEmpty
                  ? Row(
                      children: [
                        SizedBox(width: 16),
                        Expanded(
                          child: PlanCard(
                            plan: library.plans.first,
                            width: null,
                            height: side,
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Nothing scheduled',
                        style: Theme.of(context).textTheme.headline6.apply(
                            color: Theme.of(context).disabledColor,
                            fontWeightDelta: -1),
                      ),
                    );
            }),
            SizedBox(height: MediaQuery.of(context).size.height / 3),
          ],
        ),
      ),
    );
  }
}

class ListTitle extends StatelessWidget {
  const ListTitle({
    Key key,
    @required this.context,
    @required this.title,
    @required this.button,
    this.onButtonTap,
    this.subtitle,
  }) : super(key: key);

  final BuildContext context;
  final String title;
  final String button;
  final String subtitle;
  final void Function() onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .apply(fontWeightDelta: 0)
                    .copyWith(),
              ),
              subtitle != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    )
                  : SizedBox(height: 0),
            ],
          ),
          // Text(button),
          TextButton(
            // style: ButtonStyle().copyWith(
            // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            // minimumSize:
            // MaterialStateProperty.resolveWith((states) => Size.zero),
            // padding: MaterialStateProperty.resolveWith(
            // (states) => EdgeInsets.all(0))),
            onPressed: () {
              if (onButtonTap != null) onButtonTap();
            },
            child: Text(button),
          )
        ],
      ),
    );
  }
}

enum AppBarMenuOptions { changeTheme }
