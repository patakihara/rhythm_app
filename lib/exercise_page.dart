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

class _ExercisePageState extends State<ExercisePage> {
  bool editing;
  Exercise exercise;
  bool valid;
  bool changed;

  bool fromTile;

  TextEditingController name = TextEditingController();
  TextEditingController sets = TextEditingController();
  TextEditingController reps = TextEditingController();
  TextEditingController secsStart = TextEditingController();
  TextEditingController secsRest = TextEditingController();
  TextEditingController secsUp = TextEditingController();
  TextEditingController secsDown = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    exercise = widget.exercise;
    editing = (widget.exercise == null);
    fromTile = !(widget.exercise == null);
    if (exercise != null) {
      name.text = exercise.name;
      sets.text = exercise.sets.toString();
      reps.text = exercise.reps.toString();
      secsStart.text = exercise.secsStart.toString();
      secsRest.text = exercise.secsRest.toString();
      secsUp.text = exercise.secsUp.toString();
      secsDown.text = exercise.secsDown.toString();
      changed = false;
      valid = true;
    } else {
      sets.text = '3';
      reps.text = '10';
      secsStart.text = '15';
      secsRest.text = '30';
      secsUp.text = '1.0';
      secsDown.text = '1.0';
      changed = false;
      valid = false;
    }

    var controllers = [name, sets, reps, secsStart, secsRest, secsUp, secsDown];

    for (var i = 0; i < controllers.length; i++)
      controllers[i].addListener(() {
        checkIfChanged();
        checkIfValid();
      });

    super.initState();
  }

  void checkIfChanged() {
    setState(() {
      if (exercise != null) {
        changed = !(name.text == exercise.name.toString() &&
            sets.text == exercise.sets.toString() &&
            reps.text == exercise.reps.toString() &&
            secsStart.text == exercise.secsStart.toString() &&
            secsRest.text == exercise.secsRest.toString() &&
            secsUp.text == exercise.secsUp.toString() &&
            secsDown.text == exercise.secsDown.toString());
      } else
        changed = true;
    });
  }

  void checkIfValid() {
    setState(() {
      valid = validate(name, nameValidator) &&
          validate(sets, intValidator) &&
          validate(reps, intValidator) &&
          validate(secsStart, numValidator) &&
          validate(secsRest, numValidator) &&
          validate(secsUp, numValidator) &&
          validate(secsDown, numValidator);
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
        secsUp.text = exercise.secsUp.toString();
        secsDown.text = exercise.secsDown.toString();
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
    if (exercise == null || !editing) {
      // if (fromTile)
      //   provider.Provider.of<MenuProvider>(context, listen: false).showNavBar =
      //       false;
      context.read<MenuProvider>().showNavBar = true;
      context.read<MenuProvider>().inExercisePage = false;
      context.read<MenuProvider>().openPlan = null;
      return true;
    } else {
      if (changed)
        showDialog<bool>(
            context: context,
            builder: (_) {
              return DiscardChangesDialog(context: context);
            }).then((discard) {
          if (discard)
            setState(() {
              editing = false;
              discardChanges();
            });
        });
      else
        setState(() {
          editing = false;
        });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          textTheme: Theme.of(context).textTheme,
          actionsIconTheme: Theme.of(context).iconTheme,
          iconTheme: Theme.of(context).iconTheme,
          // actions: [
          //   IconButton(icon: Icon(Icons.edit), onPressed: () {}),
          // ],
          // flexibleSpace: Material(
          //     color: Theme.of(context).colorScheme.surface, elevation: 4),
          leading: IconButton(
              icon: exercise == null || editing
                  ? Icon(Icons.close)
                  : Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(
                  context, exercise != null ? exercise.name : null)),
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
                        controller: secsUp,
                        labelText: 'Up time',
                        suffixText: 'secs',
                        keyboardType: TextInputType.number,
                        validator: numValidator),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedTextField(
                        editing: editing,
                        controller: secsDown,
                        labelText: 'Down time',
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
                    color: changed && valid || !editing
                        ? Theme.of(context).iconTheme.color
                        : Theme.of(context).iconTheme.color.withOpacity(0.38)),
                onPressed: changed && valid || !editing
                    ? () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          editing = !editing;
                          if (!editing) {
                            _scaffoldKey.currentState.showSnackBar(
                                SnackBar(content: Text('Exercise saved')));
                            var newExercise = Exercise(
                                name: name.text,
                                sets: int.parse(sets.text),
                                reps: int.parse(reps.text),
                                secsStart: num.parse(secsStart.text),
                                secsRest: num.parse(secsRest.text),
                                secsUp: num.parse(secsUp.text),
                                secsDown: num.parse(secsDown.text));
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
                builder: (context, nowPlaying, child) => AnimatedContainer(
                  margin: EdgeInsets.only(
                      right: !editing && nowPlaying.empty ? 0 : 28),
                  height: editing || !nowPlaying.empty ? 0 : 56,
                  width: editing || !nowPlaying.empty ? 0 : 56,
                  duration: Duration(milliseconds: 150),
                  child: FloatingActionButton(
                    heroTag: 'playButton',
                    child: AnimatedOpacity(
                      opacity: editing || !nowPlaying.empty ? 0 : 1,
                      duration: Duration(milliseconds: 150),
                      child: Icon(() {
                        // exercise == null ||
                        //       nowPlaying.empty ||
                        //       nowPlaying.exercise.name != exercise.name
                        //   ? Icon(Icons.play_arrow)
                        //   : Icon(Icons.stop),
                        if (exercise == null || nowPlaying.empty)
                          return Icons.play_arrow;
                        else if (nowPlaying.exercise.name != exercise.name) {
                          if (nowPlaying.plan.exerciseNames
                              .contains(exercise.name)) {
                            bool check() =>
                                nowPlaying.plan.exerciseNames
                                    .indexOf(exercise.name) >
                                nowPlaying.plan.exerciseNames
                                    .indexOf(nowPlaying.exercise.name);
                            if (check())
                              return Icons.fast_forward;
                            else
                              return Icons.fast_rewind;
                          } else
                            return Icons.play_arrow;
                        } else
                          return Icons.stop;
                      }()),
                    ),
                    onPressed: () {
                      bool notCurrentlyPlaying() =>
                          nowPlaying.exercise.name != exercise.name;
                      if (nowPlaying.empty) {
                        nowPlaying.changePlan(Plan.fromList('', [exercise.name])
                            .withParent(exercise.parent));
                      } else if (notCurrentlyPlaying()) {
                        if (nowPlaying.plan.exerciseNames
                            .contains(exercise.name)) {
                          bool check() =>
                              nowPlaying.plan.exerciseNames
                                  .indexOf(exercise.name) >
                              nowPlaying.plan.exerciseNames
                                  .indexOf(nowPlaying.exercise.name);
                          if (check())
                            while (notCurrentlyPlaying())
                              nowPlaying.skipForward();
                          else
                            while (notCurrentlyPlaying())
                              nowPlaying.skipBackward();
                        } else {
                          nowPlaying.changePlan(
                              Plan.fromList('', [exercise.name])
                                  .withParent(exercise.parent));
                        }
                      } else
                        nowPlaying.clear();
                    },
                  ),
                ),
              ),
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
