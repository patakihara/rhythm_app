import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
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
      Provider.of<NowPlaying>(context, listen: false).updateTime();
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
    return Consumer<NowPlaying>(
      builder: (context, nowPlaying, child) => Stack(
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
                    : Theme.of(context).colorScheme.secondary.withOpacity(.08),
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
                      Timer(
                        Provider.of<MenuProvider>(
                          context,
                          listen: false,
                        ).pageTransitionDuration,
                        () => Provider.of<NowPlaying>(
                          context,
                          listen: false,
                        ).clear(),
                      );
                      // Navigator.pop(context);
                    }),
              ],
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  // Navigator.pop(context);
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
