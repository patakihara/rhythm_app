import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rubber/rubber.dart';

class MenuPageOld extends StatefulWidget {
  MenuPageOld({Key key}) : super(key: key);

  @override
  _MenuPageOldState createState() => _MenuPageOldState();
}

class _MenuPageOldState extends State<MenuPageOld>
    with TickerProviderStateMixin {
  RubberAnimationController _controller;
  final height = 50.0;

  // AnimationController myController;
  Animation<double> secondChildFadeAnimation;
  Animation<double> firstChildFadeAnimation;
  Animation<Alignment> alignmentAnim;
  Animation<double> sizeAnimation;
  Animation<double> topAnim;
  Animation<double> leftAnim;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = RubberAnimationController(
        vsync: this,
        dismissable: true,
        springDescription: SpringDescription.withDampingRatio(
          mass: 1,
          stiffness: Stiffness.VERY_LOW,
          ratio: DampingRatio.NO_BOUNCY,
        ),
        // animationBehavior: AnimationBehavior.preserve,
        // initialValue: 72 / MediaQuery.of(context).size.height * 100,
        lowerBoundValue: AnimationControllerValue(pixel: 72),
        upperBoundValue:
            AnimationControllerValue(pixel: MediaQuery.of(context).size.height),
        duration: Duration(milliseconds: 200));
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
      end: Alignment.topCenter,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          72 / MediaQuery.of(context).size.height,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    topAnim = Tween<double>(
            begin: 0, end: 56 + MediaQuery.of(context).viewPadding.top + 24)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          72 / MediaQuery.of(context).size.height,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    leftAnim = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          72 / MediaQuery.of(context).size.height,
          1,
          curve: Curves.linear,
        ),
      ),
    );

    sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.addListener(() {
      // print(_controller.value * MediaQuery.of(context).size.height);
    });
  }

  void _expand() {
    print("expand");
    _controller.launchTo(_controller.value, _controller.upperBound,
        velocity: 2);
  }

  CrossFadeState myCol = CrossFadeState.showFirst;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // title: Text(
      //   "Menu",
      //   style: TextStyle(color: Colors.cyan[900]),
      // ),
      // ),
      body: Container(
        child: RubberBottomSheet(
          lowerLayer: _getLowerLayer(),
          upperLayer: _getUpperLayer(),
          animationController: _controller,
          onTap: _expand,
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
    return Container(
      decoration: BoxDecoration(color: Colors.cyan[100]),
    );
  }

  Widget _getUpperLayer() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox.expand(
            child: Container(
                color: Colors.brown,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: secondChildFadeAnimation.value < 0.089
                          ? 0
                          : secondChildFadeAnimation.value,
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text('App bar'),
                        ),
                        body: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_down_outlined,
                                      size: 34,
                                      color: Colors.white70,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Tumbo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .copyWith(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.thumb_up_outlined,
                                      size: 34,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                'Tekno',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: SliderTheme(
                                  data: SliderThemeData(
                                      thumbColor: Colors.white,
                                      activeTrackColor: Colors.white70,
                                      inactiveTrackColor: Colors.white24),
                                  child: Slider(
                                    value: 2,
                                    max: 10,
                                    min: 1,
                                    onChanged: (double value) {},
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '0:17',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                    Text(
                                      '2:43',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.shuffle_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.skip_previous_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.play_arrow_rounded,
                                          color: Colors.white, size: 48),
                                    ),
                                    Icon(
                                      Icons.skip_next_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.repeat_one_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Opacity(
                          opacity: firstChildFadeAnimation.value,
                          child: Align(
                            alignment: Alignment(-0.4, -0.9),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tekno',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  // SizedBox(
                                  //   height: 8.0,
                                  // ),
                                  Text(
                                    'Tumbo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: firstChildFadeAnimation.value,
                          child: Align(
                            alignment: Alignment(0.9, 0.0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white70,
                                    size: 35,
                                  ),
                                  Icon(
                                    Icons.skip_next_rounded,
                                    color: Colors.white70,
                                    size: 35,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: alignmentAnim.value,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: leftAnim.value,
                              top: topAnim.value,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.all(0),
                              width: sizeAnimation.value,
                              height: sizeAnimation.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )));
      },
    );
  }
}
