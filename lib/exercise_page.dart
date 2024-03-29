import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'providers.dart';
import 'widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'classes.dart';

class ExercisePage extends StatefulWidget {
  final Exercise exercise;
  final bool fromPlanPage;

  const ExercisePage({Key key, this.exercise, this.fromPlanPage = false})
      : super(key: key);
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage>
    with TickerProviderStateMixin {
  bool __editing;
  bool _valid;
  bool _changed;
  bool _deleting;

  bool get editing => __editing;
  bool get valid => _valid;
  bool get changed => _changed;
  bool get deleting => _deleting;

  set editing(bool value) {
    setState(() {
      __editing = value;
    });
    if (value)
      editStateController.fling();
    else
      editStateController.fling(velocity: -1);
  }

  AnimationController editStateController;
  Animation<double> fabSize;

  AnimationController playStateController;

  Exercise exercise;

  bool fromTile;

  TextEditingController name = TextEditingController();
  TextEditingController sets = TextEditingController();
  TextEditingController reps = TextEditingController();
  TextEditingController secsStart = TextEditingController();
  TextEditingController secsRest = TextEditingController();
  TextEditingController secsTic = TextEditingController();
  TextEditingController secsToc = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    exercise = widget.exercise;
    _deleting = false;
    __editing = (widget.exercise == null);
    fromTile = !(widget.exercise == null);
    if (exercise != null) {
      name.text = exercise.name;
      sets.text = exercise.sets.toString();
      reps.text = exercise.reps.toString();
      secsStart.text = exercise.secsStart.toString();
      secsRest.text = exercise.secsRest.toString();
      secsTic.text = exercise.ticTime.toString();
      secsToc.text = exercise.tocTime.toString();
      _changed = false;
      _valid = true;
    } else {
      sets.text = '3';
      reps.text = '10';
      secsStart.text = '15';
      secsRest.text = '30';
      secsTic.text = '1.0';
      secsToc.text = '1.0';
      _changed = false;
      _valid = false;
    }

    var controllers = [name, sets, reps, secsStart, secsRest, secsTic, secsToc];

    for (var i = 0; i < controllers.length; i++)
      controllers[i].addListener(() {
        checkIfChanged();
        checkIfValid();
      });

    editStateController =
        AnimationController(vsync: this, value: editing ? 1 : 0);
    fabSize = Tween<double>(begin: 56, end: 0).animate(
      CurvedAnimation(
        parent: editStateController,
        curve: Curves.ease,
      ),
    );

    playStateController = AnimationController(vsync: this);

    super.initState();
  }

  void checkIfChanged() {
    setState(() {
      if (exercise != null) {
        _changed = !(name.text == exercise.name.toString() &&
            sets.text == exercise.sets.toString() &&
            reps.text == exercise.reps.toString() &&
            secsStart.text == exercise.secsStart.toString() &&
            secsRest.text == exercise.secsRest.toString() &&
            secsTic.text == exercise.ticTime.toString() &&
            secsToc.text == exercise.tocTime.toString());
      } else
        _changed = true;
    });
  }

  void checkIfValid() {
    setState(() {
      _valid = validate(name, nameValidator) &&
          validate(sets, intValidator) &&
          validate(reps, intValidator) &&
          validate(secsStart, numValidator) &&
          validate(secsRest, numValidator) &&
          validate(secsTic, numValidator) &&
          validate(secsToc, numValidator);
    });
  }

  void discardChanges() {
    if (exercise != null) {
      setState(() {
        name.text = exercise.name;
        sets.text = exercise.sets.toString();
        reps.text = exercise.reps.toString();
        secsStart.text = exercise.secsStart.toString();
        secsRest.text = exercise.secsRest.toString();
        secsTic.text = exercise.ticTime.toString();
        secsToc.text = exercise.tocTime.toString();
      });
      FocusScope.of(context).unfocus();
    }
  }

  String nameValidator(String value) {
    var counts = provider.Provider.of<Library>(context, listen: false)
        .exerciseNameCounts;
    if (value.isEmpty) {
      return 'You have to enter a name.';
    } else if (counts[name] == null) {
      return null;
    } else if (exercise == null) {
      return 'Exercise already exists.';
    } else if (counts[name] > 1) {
      return 'Exercise already exists.';
    } else if (value != exercise.name) {
      return 'Exercise already exists.';
    } else {
      return null;
    }
  }

  String intValidator(String value) {
    return int.tryParse(value) == null ? 'Must be an integer.' : null;
  }

  String numValidator(String value) {
    return num.tryParse(value) == null ? 'Must be a number.' : null;
  }

  bool validate(TextEditingController controller,
      String Function(String value) validator) {
    return validator(controller.text) == null;
  }

  Future<bool> onBackPressed() async {
    bool close = false;

    if ((exercise == null || !editing) && !deleting) {
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
      if (deleting) context.read<Library>().removeExercise(exercise);
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
    context.read<MenuProvider>().inExercisePage = false;
    context.read<MenuProvider>().openExercise = null;
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<NowPlaying>().playing &&
        context.watch<NowPlaying>().plan.name == '' &&
        exercise != null &&
        context.watch<NowPlaying>().exercise.name == exercise.name &&
        playStateController.isDismissed) {
      playStateController.fling();
    } else if (!context.watch<NowPlaying>().playing &&
        playStateController.isCompleted) {
      playStateController.fling(velocity: -1);
    }

    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          textTheme: Theme.of(context).textTheme,
          actionsIconTheme: Theme.of(context).iconTheme,
          iconTheme: Theme.of(context).iconTheme,
          leading: IconButton(
            icon: exercise == null || editing
                ? Icon(Icons.close)
                : Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(
                context, exercise != null ? exercise.name : null),
          ),
          actions: [
            IconButton(
              icon: AnimatedBuilder(
                animation: editStateController,
                builder: (context, child) => Opacity(
                  opacity: exercise == null ? 0 : editStateController.value,
                  child: Icon(
                    Icons.delete,
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _deleting = true;
                });
                Navigator.maybePop(
                    context, exercise != null ? exercise.name : null);
              },
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(96),
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
                          builder: (context, library, child) => TextFormField(
                            autofocus: editing &&
                                exercise == null &&
                                (name.text.isEmpty),
                            readOnly: !editing,
                            controller: name,
                            textCapitalization: TextCapitalization.sentences,
                            autocorrect: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: nameValidator,
                            decoration: InputDecoration(
                                // labelText: 'Name',
                                hintText: 'New exercise',
                                border: InputBorder.none),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .apply(fontWeightDelta: 1),
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
        body: Padding(
          padding: const EdgeInsets.only(top: 48.0, left: 20, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 24, top: 16, bottom: 16),
                    child: Icon(MdiIcons.repeat, size: 24),
                  ),
                  Expanded(
                    child: AnimatedTextField(
                      editing: editing,
                      labelText: 'Sets',
                      controller: sets,
                      keyboardType: TextInputType.number,
                      validator: intValidator,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedTextField(
                        editing: editing,
                        labelText: 'Reps',
                        controller: reps,
                        keyboardType: TextInputType.number,
                        validator: intValidator),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 24, top: 16, bottom: 16),
                    child: Icon(MdiIcons.timerOutline, size: 24),
                  ),
                  Expanded(
                    child: AnimatedTextField(
                        editing: editing,
                        suffixText: 'secs',
                        labelText: 'Ready time',
                        controller: secsStart,
                        keyboardType: TextInputType.number,
                        validator: numValidator),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedTextField(
                        editing: editing,
                        suffixText: 'secs',
                        labelText: 'Rest time',
                        controller: secsRest,
                        keyboardType: TextInputType.number,
                        validator: numValidator),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 24.0 + 24.0),
                  Expanded(
                    child: AnimatedTextField(
                        editing: editing,
                        controller: secsTic,
                        labelText: 'Tic time',
                        suffixText: 'secs',
                        keyboardType: TextInputType.number,
                        validator: numValidator),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedTextField(
                        editing: editing,
                        controller: secsToc,
                        labelText: 'Toc time',
                        suffixText: 'secs',
                        keyboardType: TextInputType.number,
                        validator: numValidator),
                  ),
                ],
              ),
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
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
                    Theme.of(context).colorScheme.background),
                child: Icon(editing ? Icons.save : Icons.edit,
                    color: (changed && valid) || !editing
                        ? Theme.of(context).iconTheme.color
                        : Theme.of(context).iconTheme.color.withOpacity(0.38)),
                onPressed: (changed && valid) || !editing
                    ? () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          editing = !editing;
                          if (!editing) {
                            setState(() {
                              _changed = false;
                            });
                            _scaffoldKey.currentState.showSnackBar(
                                SnackBar(content: Text('Exercise saved')));
                            var newExercise = Exercise(
                                name: name.text,
                                sets: int.parse(sets.text),
                                reps: int.parse(reps.text),
                                secsStart: num.parse(secsStart.text),
                                secsRest: num.parse(secsRest.text),
                                ticTime: num.parse(secsTic.text),
                                tocTime: num.parse(secsToc.text));
                            if (exercise == null) {
                              exercise = newExercise;
                              provider.Provider.of<Library>(context,
                                      listen: false)
                                  .addExercise(exercise);
                              print('Exercise key: ' + exercise.key);
                            } else {
                              provider.Provider.of<Library>(context,
                                      listen: false)
                                  .swapExercise(exercise, newExercise);
                              exercise = newExercise;
                            }
                          }
                        });
                        if (widget.fromPlanPage)
                          Navigator.maybePop<String>(context, exercise.name);
                      }
                    : null,
                mini: true,
              ),

              provider.Consumer<NowPlaying>(
                builder: (context, nowPlaying, child) => AnimatedBuilder(
                  animation: editStateController,
                  builder: (context, child) => Padding(
                    padding: EdgeInsets.all((56 - fabSize.value.abs()) / 2),
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
                                  (nowPlaying.plan.name != '' &&
                                      nowPlaying.exercise.name !=
                                          exercise.name))
                                nowPlaying.changePlan(
                                    Plan.fromList('', [exercise.name])
                                        .withParent(exercise.parent));
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

              // AnimatedContainer(
              //   margin: EdgeInsets.only(right: !editing ? 0 : 28),
              //   height: editing ? 0 : 56,
              //   width: editing ? 0 : 56,
              //   duration: Duration(milliseconds: 150),
              //   child: provider.Consumer<NowPlaying>(
              //     builder: (context, nowPlaying, child) => FloatingActionButton(
              //       heroTag: 'playButton',
              //       child: AnimatedOpacity(
              //         opacity: editing ? 0 : 1,
              //         duration: Duration(milliseconds: 150),
              //         child: exercise == null ||
              //                 nowPlaying.empty ||
              //                 nowPlaying.exercise.name != exercise.name ||
              //                 !nowPlaying.playing
              //             ? Icon(Icons.play_arrow)
              //             : Icon(Icons.pause),
              //       ),
              //       onPressed: () {
              //         if (nowPlaying.empty ||
              //             nowPlaying.exercise.name != exercise.name)
              //           nowPlaying.changePlan(Plan.fromList('', [exercise.name])
              //               .withParent(exercise.parent));
              //         else
              //           nowPlaying.togglePlay();
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        // bottomNavigationBar: AnimatedPlayCard(),
        // bottomNavigationBar: AnimatedBottomBar(
        //   child: Column(children: [AnimatedPlayCard(progressOnTop: true)]),
        // ),
      ),
    );
  }
}

class AnimatedTextField extends StatelessWidget {
  final bool editing;
  final String suffixText;
  final String labelText;
  final TextInputType keyboardType;
  final String Function(String value) validator;
  final TextEditingController controller;

  AnimatedTextField(
      {Key key,
      @required this.editing,
      this.suffixText,
      @required this.labelText,
      this.keyboardType,
      this.validator,
      @required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration:
          provider.Provider.of<MenuProvider>(context).navBarTransitionDuration,
      crossFadeState:
          editing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      secondChild: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          enableInteractiveSelection: false,
          decoration: InputDecoration(
            // focusColor: Theme.of(context).colorScheme.onSurface,
            suffixText: suffixText,
            filled: true,
            border: InputBorder.none,
            labelText: labelText,
          ),
        ),
      ),
      firstChild: TextFormField(
        controller: controller,
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          // focusColor: Theme.of(context).colorScheme.onSurface,
          suffixText: suffixText,
          filled: true,
          border: UnderlineInputBorder(),
          labelText: labelText,
        ),
        autovalidateMode: AutovalidateMode.always,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}
