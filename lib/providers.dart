import 'dart:ffi';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'classes.dart';
import 'home_page.dart';
// import 'package:audioplayers/audio_cache.dart';
// import 'package:sounds/sounds.dart';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'main.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'themes.dart';

// class BackgroundPlayer extends BackgroundAudioTask {
//   final NowPlaying nowPlaying;

//   final controlsPlaying = [
//     MediaControl.skipToPrevious,
//     MediaControl.pause,
//     MediaControl.skipToNext
//   ];
//   final controlsPaused = [
//     MediaControl.skipToPrevious,
//     MediaControl.play,
//     MediaControl.skipToNext
//   ];

//   final actionsPlaying = [
//     MediaAction.skipToPrevious,
//     MediaAction.pause,
//     MediaAction.skipToNext
//   ];
//   final actionssPaused = [
//     MediaAction.skipToPrevious,
//     MediaAction.play,
//     MediaAction.skipToNext
//   ];

//   BackgroundPlayer(this.nowPlaying);

//   onStart(Map<String, dynamic> map) {
//     AudioServiceBackground.setState(
//         controls: controlsPlaying,
//         processingState: AudioProcessingState.stopped,
//         playing: true);
//   }

//   // Handle a request to stop audio and finish the task.
//   onStop() async {
//     nowPlaying.clear();
//     AudioServiceBackground.setState(
//         controls: null,
//         processingState: AudioProcessingState.stopped,
//         playing: false);
//   }

//   // Handle a request to play audio.
//   onPlay() {
//     if (nowPlaying.playing) return null;
//     nowPlaying.play();
//     AudioServiceBackground.setState(
//         playing: true,
//         controls: controlsPlaying,
//         processingState: AudioProcessingState.none);
//   }

//   // Handle a request to pause audio.
//   onPause() {
//     if (nowPlaying.playing) return null;
//     nowPlaying.play();
//     AudioServiceBackground.setState(
//         playing: false,
//         controls: controlsPaused,
//         processingState: AudioProcessingState.none);
//   }

//   // Handle a headset button click (play/pause, skip next/prev).
//   onClick(MediaButton button) {
//     switch (button) {
//       case MediaButton.media:
//         {
//           if (nowPlaying.playing)
//             onPause();
//           else
//             onPlay();
//         }
//         break;

//       case MediaButton.next:
//         {
//           onSkipToNext();
//         }
//         break;

//       case MediaButton.previous:
//         {
//           onSkipToPrevious();
//         }
//         break;
//     }
//   }

//   // Handle a request to skip to the next queue item.
//   onSkipToNext() {
//     // nowPlaying.skipNext();
//   }

//   // Handle a request to skip to the previous queue item.
//   onSkipToPrevious() {
//     // nowPlaying.skipPrevious();
//   }
// }

class Library extends ChangeNotifier {
  LibraryManager<Exercise> _exercisesManager;
  LibraryManager<Plan> _plansManager;
  final Map<String, Exercise> exercisesMap = {};
  final Map<String, Plan> plansMap = {};

  Library() {
    _plansManager = LibraryManager<Plan>(library: this);
    _exercisesManager = LibraryManager<Exercise>(library: this);
  }

  void getExercisesFromStorage() {
    exercisesMap.clear();
    var newMap = _exercisesManager.dataMap.toNameObjectMap();
    print('New map (in library): ' + newMap.toString());
    newMap.forEach((key, value) => newMap[key].parent = this);
    exercisesMap.addAll(newMap);
    notifyListeners();
  }

  void getPlansFromStorage() {
    plansMap.clear();
    var newMap = _plansManager.dataMap.toNameObjectMap();
    print('New map (in library): ' + newMap.toString());
    newMap.forEach((key, value) => newMap[key].parent = this);
    plansMap.addAll(newMap);
    notifyListeners();
  }

  List<String> get exerciseNames {
    List<String> res = exercisesMap.keys.toList();
    res.sort();
    return res;
  }

  List<Exercise> get exercises {
    var res = <Exercise>[];
    for (var i = 0; i < exerciseNames.length; i++) {
      res.add(exercisesMap[exerciseNames[i]]);
    }
    return res;
  }

  List<String> get planNames {
    List<String> res = plansMap.keys.toList();
    res.sort((a, b) => a.toString().compareTo(b.toString()));
    return res;
  }

  List<Plan> get plans {
    var res = <Plan>[];
    for (var i = 0; i < planNames.length; i++) {
      res.add(plansMap[planNames[i]]);
    }
    return res;
  }

  Map get exerciseNameCounts {
    var counts = Map();
    exerciseNames.forEach(
        (x) => counts[x] = !counts.containsKey(x) ? (1) : (counts[x] + 1));
    return counts;
  }

  Map get planNameCounts {
    var counts = Map();
    planNames.forEach(
        (x) => counts[x] = !counts.containsKey(x) ? (1) : (counts[x] + 1));
    return counts;
  }

  bool availableExerciseName(String name) {
    return !exerciseNames.contains(name);
  }

  bool containsExercise(String name) {
    return !availableExerciseName(name);
  }

  bool availablePlanName(String name) {
    return !planNames.contains(name);
  }

  bool containsPlan(String name) {
    return !availablePlanName(name);
  }

  void addExercise(Exercise exercise) {
    assert(availableExerciseName(exercise.name),
        '[Library.addExercise] Exercise with this name already exists');
    exercisesMap[exercise.name] = (exercise.withParent(this));
    _exercisesManager.add(exercise);
    print('[Library.addExericse] New map (in manager): ' +
        _exercisesManager.dataMap.toString());
    notifyListeners();
  }

  void swapExercise(Exercise oldExercise, Exercise newExercise) {
    var case1 = exerciseNameCounts[newExercise.name] == null;
    var case2 = exerciseNameCounts[newExercise.name] == 1 &&
        oldExercise.name == newExercise.name;
    assert(containsExercise(oldExercise.name));
    assert(case1 || case2, 'Exercise with this name already exists');

    newExercise = newExercise.withParent(this, key: oldExercise.key);

    if (case2) {
      exercisesMap[newExercise.name] = newExercise;
    } else {
      exercisesMap[newExercise.name] = newExercise;
      exercisesMap.remove(oldExercise.name);
      for (var i = 0; i < plans.length; i++) {
        if (plans[i].contains(oldExercise.name)) {
          plansMap[plans[i].name].replace(oldExercise.name, newExercise.name);
        }
      }
    }
    _exercisesManager.swap(oldExercise, newExercise);

    notifyListeners();
  }

  void addPlan(Plan plan) {
    assert(availablePlanName(plan.name), 'Plan with this name already exists');
    plansMap[plan.name] = plan.withParent(this);
    _plansManager.add(plan);

    notifyListeners();
  }

  void swapPlan(Plan oldPlan, Plan newPlan) {
    var case1 = planNameCounts[newPlan.name] == null;
    var case2 =
        planNameCounts[newPlan.name] == 1 && oldPlan.name == newPlan.name;
    assert(containsPlan(oldPlan.name));
    assert(case1 || case2, 'Plan with this name already exists');

    newPlan = newPlan.withParent(this, key: oldPlan.key);

    plansMap.remove(oldPlan.name);
    plansMap[newPlan.name] = newPlan;
    _plansManager.swap(oldPlan, newPlan);

    notifyListeners();
  }

  void fixOrphans() {
    for (var i = 0; i < plans.length; i++) {
      swapPlan(plans[i], plans[i]);
    }
    for (var i = 0; i < exercises.length; i++) {
      swapExercise(exercises[i], exercises[i]);
    }
    notifyListeners();
  }

  void fixDeadChildren() {
    for (var i = 0; i < planNames.length; i++) {
      var j = 0;
      while (j < plansMap[planNames[i]].exerciseNames.length) {
        if (!containsExercise(plansMap[planNames[i]].exerciseNames[j])) {
          plansMap[planNames[i]]
              .exerciseNames
              .remove(plansMap[planNames[i]].exerciseNames[j]);
        } else {
          j++;
        }
      }
    }
  }

  void fixKeys() {
    for (var i = 0; i < planNames.length; i++) {
      if (plansMap[planNames[i]].key == null)
        plansMap[planNames[i]]
            .key
            .replaceRange(0, null, DateTime.now().toString());
    }
    for (var i = 0; i < exerciseNames.length; i++) {
      if (exercisesMap[exerciseNames[i]].key == null)
        exercisesMap[exerciseNames[i]]
            .key
            .replaceRange(0, null, DateTime.now().toString());
    }
    notifyListeners();
  }
}

class MenuProvider extends ChangeNotifier {
  Menu _menu = Menu.timers;
  TabMenu _tabMenu = TabMenu.plans;
  Menu _previousMenu;
  Plan _openPlan;
  Exercise _openExercise;
  bool _showNavBar = false; //true;
  bool _inPlanPage = false;
  bool _inExercisePage = false;
  bool _appBarElevated = false;
  double _playCardHeight = 72;
  double _navBarHeight = 56;

  final Duration pageTransitionDuration = Duration(milliseconds: 300);
  final Duration navBarTransitionDuration = Duration(milliseconds: 100);
  final Duration navBarTransitionWait = Duration(milliseconds: 300);

  bool get showNavBar => _showNavBar;

  set showNavBar(bool value) {
    _showNavBar = value;
    notifyListeners();
  }

  bool get inPlanPage => _inPlanPage;

  set inPlanPage(bool value) {
    _inPlanPage = value;
    notifyListeners();
  }

  bool get inExercisePage => _inExercisePage;

  set inExercisePage(bool value) {
    _inExercisePage = value;
    notifyListeners();
  }

  bool get appBarElevated => _appBarElevated;

  set appBarElevated(bool value) {
    _appBarElevated = value;
    notifyListeners();
  }

  double get playCardHeight => _playCardHeight;

  double get navBarBarHeight => _navBarHeight;

  set navBarBarHeight(double value) {
    _navBarHeight = 0; //value;
    notifyListeners();
  }

  Menu get menu {
    return _menu;
  }

  set menu(Menu menu) {
    _previousMenu = _menu;
    _menu = menu;
    notifyListeners();
  }

  TabMenu get tabMenu {
    return _tabMenu;
  }

  set tabMenu(TabMenu tabMenu) {
    _tabMenu = tabMenu;
    notifyListeners();
  }

  Menu get previousMenu {
    return _previousMenu;
  }

  Plan get openPlan {
    return _openPlan;
  }

  set openPlan(Plan plan) {
    _openPlan = plan;
    notifyListeners();
  }

  Exercise get openExercise {
    return _openExercise;
  }

  set openExercise(Exercise exercise) {
    _openExercise = exercise;
    notifyListeners();
  }

  Widget get menuWidget {
    if (menu == Menu.home)
      return HomeMenu();
    else if (menu == Menu.timers)
      return TimersMenu();
    else if (menu == Menu.calendar) return CalendarMenu();
  }
}

enum Menu { home, timers, calendar }

enum TabMenu { plans, exercises }

class NowPlaying extends ChangeNotifier {
  NowPlaying._privateContructor();

  static final NowPlaying _instance = NowPlaying._privateContructor();

  factory NowPlaying() {
    return _instance;
  }

  Plan plan;
  int _exerciseIndex = 0;
  num time = 0;
  num setTime = 0;
  ExerciseTimer exerciseTimer;
  RepState repState = RepState.rest;
  bool _cleared = false;
  bool _serviceStarted = false;

  // if using audioplayers:
  // AudioCache audioPlayer1 = AudioCache();
  // AudioCache audioPlayer2 = AudioCache();

  // if using just audio:
  // final audioPlayer1 = AudioPlayer();
  // final audioPlayer2 = AudioPlayer();

  // void setUpPlayers() async {
  //   if (!_playersSetUp) {
  //     await audioPlayer1.setAsset('assets/woodblock.mp3');
  //     await audioPlayer2.setAsset('assets/drumsticks.mp3');
  //     _playersSetUp = true;
  //   }
  // }

  int get exerciseIndex => _exerciseIndex;

  bool get empty {
    return plan == null || _cleared;
  }

  bool get playing {
    if (empty) {
      return false;
    } else {
      return exerciseTimer.playing;
    }
  }

  bool get ended {
    if (empty) {
      return false;
    } else {
      return exerciseTimer.ended && isLast;
    }
  }

  Exercise get exercise {
    if (empty && plan == null)
      return null;
    else
      return plan.exercises[_exerciseIndex];
  }

  num get duration {
    if (empty)
      return 0;
    else
      return exercise.duration;
  }

  int get timerIndex {
    if (empty)
      return -1;
    else
      return exerciseTimer.index;
  }

  double get percent {
    if (empty)
      return 0;
    else
      return time / duration;
  }

  double get setPerc {
    if (empty)
      return 0;
    else if (exerciseTimer.ended)
      return 1.0;
    else {
      var perc = setTime / exercise.durations[timerIndex];
      return perc > 1 ? 1 : perc;
    }
  }

  int get currentSet {
    if (empty)
      return 0;
    else if (exerciseTimer.ended)
      return exercise.sets;
    else
      return exercise.setNums[timerIndex];
  }

  int get currentRep {
    if (empty)
      return 0;
    else
      return (setPerc * exercise.reps + 0.5).floor();
  }

  bool get inReady {
    if (empty)
      return true;
    else if (exerciseTimer.ended) return false;
    return exercise.phases[timerIndex] == ExercisePhase.ready;
  }

  bool get inRest {
    if (empty || exerciseTimer.ended)
      return false;
    else
      return exercise.phases[timerIndex] == ExercisePhase.rest;
  }

  bool get inSet {
    if (empty || exerciseTimer.ended)
      return false;
    else
      return exercise.phases[timerIndex] == ExercisePhase.active;
  }

  bool get inEnd {
    if (empty)
      return false;
    else if (exerciseTimer.ended)
      return true;
    else
      return exercise.phases[timerIndex] == ExercisePhase.end;
  }

  bool get isFirst {
    if (empty)
      return false;
    else
      return (_exerciseIndex == 0);
  }

  bool get isLast {
    if (empty)
      return null;
    else
      return (_exerciseIndex == plan.exercises.length - 1);
  }

  // void startAudioService() async {
  //   if (_serviceStarted) return;
  //   ServiceStarter.startService();
  // }

  // void stopAudioService() async {
  //   if (!_serviceStarted) return;
  //   await AudioService.stop();
  // }

  // void playAudioService() async {
  //   await AudioService.connect();
  //   AudioService.play();
  // }

  // void pauseAudioService() async {
  //   await AudioService.connect();
  //   AudioService.pause();
  // }

  void updateTime() {
    if (exerciseTimer == null) return;
    // if (time == exerciseTimer.elapsedSeconds) return;
    time = exerciseTimer.elapsedSeconds;
    setTime = exerciseTimer.elapsedSubSeconds;
    // print('Time updated');
    notifyListeners();
  }

  void _repStateUp() {
    repState = RepState.up;
    // audioPlayer1.seek(Duration(microseconds: 0));
    // audioPlayer1.play();
    notifyListeners();
  }

  void _repStateDown() {
    repState = RepState.down;
    // audioPlayer2.seek(Duration(microseconds: 0));
    // audioPlayer2.play();
    notifyListeners();
  }

  void _repStateRest() {
    repState = RepState.rest;
    notifyListeners();
  }

  Future<void> changePlan(Plan newPlan) async {
    clear();
    _cleared = false;
    plan = newPlan;
    print('Now playing: ' + plan.name);
    print('Exercises: ' + plan.exerciseNames.toString());
    print('First exercise:' + plan.exercises.first.name);
    _exerciseIndex = 0;
    exerciseTimer = ExerciseTimer(
        exercise, updateTime, _repStateUp, _repStateDown, _repStateRest);
    exerciseTimer.play();
    print('changedPlan');
    // startAudioService();
    // playAudioService();
    notifyListeners();
  }

  // void clearPlan() {
  //   plan = null;
  //   _exerciseIndex = 0;
  //   exerciseTimer = null;
  //   notifyListeners();
  // }

  void skipForward() {
    if (!isLast) {
      bool wasPlaying = playing;
      exerciseTimer.cancel();
      _exerciseIndex = _exerciseIndex + 1;
      exerciseTimer = ExerciseTimer(
          exercise, updateTime, _repStateUp, _repStateDown, _repStateRest);
      if (wasPlaying) exerciseTimer.play();
      notifyListeners();
      updateTime();
    }
  }

  void skipNext() {
    if (exerciseTimer.ended)
      skipForward();
    else
      exerciseTimer.skipNext();
    updateTime();
  }

  void skipBackward() {
    if (!isFirst) {
      print('skipped to previous');
      bool wasPlaying = playing;
      exerciseTimer.cancel();
      _exerciseIndex = _exerciseIndex - 1;
      exerciseTimer = ExerciseTimer(
          exercise, updateTime, _repStateUp, _repStateDown, _repStateRest);
      updateTime();
      if (wasPlaying) exerciseTimer.play();
      notifyListeners();
    }
  }

  void skipPrevious() {
    if (time < 1 && !isFirst) {
      skipBackward();
      for (var i = 0; i < exerciseTimer.timers.length - 1; i++) skipNext();
    } else {
      exerciseTimer.skipPrevious();
      updateTime();
    }
  }

  void togglePlay() {
    // startAudioService();
    if (!playing) {
      play();
      // playAudioService();
    } else {
      pause();
      // pauseAudioService();
    }
  }

  void play() {
    if (exerciseTimer.ended) {
      if (!isLast) {
        skipForward();
        exerciseTimer.play();
        notifyListeners();
        MediaNotification.showNotification(
            title: exercise.name, author: plan.name);
        return;
      }
    }
    exerciseTimer.play();
    notifyListeners();
    updateTime();
    MediaNotification.showNotification(title: exercise.name, author: plan.name);
  }

  void pause() {
    exerciseTimer.pause();
    notifyListeners();
    updateTime();
    MediaNotification.showNotification(
        title: exercise.name, author: plan.name, isPlaying: false);
  }

  void clear() {
    // stopAudioService();
    // plan = null;
    _cleared = true;
    // _exerciseIndex = 0;
    // time = 0;
    // setTime = 0;
    MediaNotification.hideNotification();
    if (plan != null) {
      if (exerciseTimer != null) {
        exerciseTimer.cancel();
        exerciseTimer = null;
        repState = RepState.rest;
      }
    }
    notifyListeners();
  }
}
