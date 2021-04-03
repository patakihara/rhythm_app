import 'dart:async';
import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:provider/provider.dart' as provider;
import 'providers.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:sounds/sounds.dart';

class LibraryManager<T extends Data> {
  File jsonFile;
  Directory dir;
  String fileName = T == Plan ? 'plans.json' : 'exercises.json';
  bool fileExists = false;
  DataMap<T> dataMap = DataMap();
  final Library library;

  LibraryManager({@required this.library}) {
    fetchFile();
  }

  Future<void> fetchFile() async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = File(dir.path + "/" + fileName);
      print("Fetching file in LibraryManager<" + T.toString() + ">");
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        print("File exists!");
        var jsonString = jsonFile.readAsStringSync();
        print('JsonString: ' + jsonString);
        var jsonMap = jsonDecode(jsonString);
        var decodedMap = DataMap<T>.fromJson(jsonMap);
        dataMap.addAll(decodedMap);
        print('Map taken from file: ' + dataMap.toString());
        if (library != null) {
          if (T == Exercise)
            library.getExercisesFromStorage();
          else
            library.getPlansFromStorage();
        }
      } else {
        print("File does not exist!");
      }
    });
  }

  void createFile() {
    print("Creating file!");
    jsonFile.createSync();
    fileExists = true;
  }

  void updateFile() {
    print("Updating file!");
    if (fileExists) {
      print("File exists");
      jsonFile.writeAsStringSync(jsonEncode(dataMap));
    } else {
      print("File does not exist!");
      createFile();
      updateFile();
    }
  }

  add(T data) {
    print("Adding to DataMap");
    dataMap.add(data);
    updateFile();
  }

  remove(T data) {
    dataMap.remove(data);
    updateFile();
  }

  swap(T oldObject, T newObject) {
    print("Swapping in DataMap");
    dataMap.swap(oldObject, newObject);
    updateFile();
  }
}

class DataMap<T extends Data> {
  final Map<String, T> _objects = {};

  DataMap();

  DataMap.fromObjects(List<T> objects) {
    for (var i = 0; i < objects.length; i++) {
      _objects[objects[i].key.toString()] = objects[i];
    }
  }

  DataMap.fromNameObjectMap(Map<String, T> objectsMap) {
    var names = objectsMap.keys.toList();
    for (var i = 0; i < names.length; i++) {
      _objects[objectsMap[names[i]].key.toString()] = objectsMap[names[i]];
    }
  }

  DataMap.fromKeyObjectMap(Map<Key, T> objects) {
    var keys = objects.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      _objects[keys[i].toString()] = objects[keys[i]];
    }
  }

  DataMap.fromJson(Map<String, dynamic> jsonMap) {
    var keys = jsonMap.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      var newKey = keys[i].split('content@').last;
      _objects[newKey] = (T == Plan)
          ? Plan.fromJson(jsonMap[keys[i]])
          : Exercise.fromJson(jsonMap[keys[i]]);
    }
  }

  Map<String, dynamic> toJson() {
    var jsonMap = <String, dynamic>{};
    var keys = _objects.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      jsonMap['content@' + keys[i]] = _objects[keys[i]].toJson();
    }
    return jsonMap;
  }

  Map<String, T> toNameObjectMap() {
    var objectsMap = <String, T>{};
    var objects = _objects.values.toList();
    for (var i = 0; i < objects.length; i++) {
      objectsMap[objects[i].name] = objects[i];
    }
    return objectsMap;
  }

  void addAll(DataMap map) {
    _objects.addAll(map._objects);
  }

  void add(T object) {
    _objects[object.key.toString()] = object;
  }

  void remove(T object) {
    assert(_objects.values.contains(object), 'Object not in map!');
    _objects.remove(object.key.toString());
  }

  void swap(T oldObject, T newObject) {
    assert(_objects.values.contains(oldObject), 'Object not in map!');
    assert(
        oldObject.key == newObject.key,
        'Objects are not swappable!\n' +
            'Keys were:\n' +
            oldObject.key +
            '\n' +
            newObject.key);
    _objects[oldObject.key.toString()] = newObject;
  }

  @override
  String toString() {
    return _objects.toString();
  }
}

// do not use
abstract class Data {
  final String name;
  String key;
  Library parent;

  Data.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        key = json['key'];
  Map<String, dynamic> toJson() => {};

  Data withParent(Library parent, {String key}) {
    this.parent = parent;
    if (key != null) {
      this.key = key;
    }
    return this;
  }
}

class Plan implements Data {
  final String name;
  // final List<Exercise> exercises;
  List<String> _exerciseNames = [];
  Library parent;
  String key;

  List<String> get exerciseNames {
    return _exerciseNames;
  }

  Plan(this.name, {this.key}) {
    if (key == null) this.key = DateTime.now().toString();
  }

  Plan.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        _exerciseNames = List<String>.from(json['_exerciseNames']),
        key = json['key'];

  Map<String, dynamic> toJson() => {
        'name': name,
        '_exerciseNames': _exerciseNames,
        'key': key.toString(),
      };

  Plan.fromList(this.name, List<String> exerciseNames, {this.key}) {
    if (this.key == null) this.key = DateTime.now().toString();
    this._exerciseNames.addAll(exerciseNames);
  }

  Plan withParent(Library parent, {String key}) {
    this.parent = parent;
    if (key != null) {
      this.key = key;
    }
    return this;
  }

  List<Exercise> get exercises {
    List<Exercise> res = [];
    for (var i = 0; i < _exerciseNames.length; i++) {
      res.add(parent.exercisesMap[_exerciseNames[i]]);
    }
    return res;
  }

  void add(String exerciseName) {
    assert(parent.containsExercise(exerciseName));
    _exerciseNames.add(exerciseName);
    parent.notifyListeners();
  }

  void replace(String oldName, newName) {
    assert(_exerciseNames.contains(oldName));
    assert(parent.containsExercise(newName));
    var ind = _exerciseNames.indexOf(oldName);
    _exerciseNames[ind] = newName;
    parent.notifyListeners();
  }

  bool contains(String exerciseName) {
    return _exerciseNames.contains(exerciseName);
  }
}

class Exercise implements Data {
  final String name;
  final int reps;
  final int sets;
  final num secsUp;
  final num secsDown;
  final num secsRest;
  final num secsStart;
  final bool upFirst;
  final List<num> _timePoints = <num>[];
  final List<num> _durations = <num>[];
  final List<int> _setNums = <int>[];
  final List<ExercisePhase> _phases = <ExercisePhase>[];
  Library parent;
  String key;

  Exercise(
      {@required this.name,
      this.reps = 3,
      this.sets = 3,
      this.secsUp = 2,
      this.secsDown = 3,
      this.secsRest = 30,
      this.secsStart = 15,
      this.upFirst = true,
      this.key}) {
    if (key == null) key = DateTime.now().toString();
    print(key);
    print(key.toString());
  }

  Exercise withParent(Library parent, {String key}) {
    this.parent = parent;
    if (key != null) {
      this.key = key;
    }
    return this;
  }

  Exercise.fromJson(Map<String, dynamic> json)
      : this.name = json['name'],
        this.reps = json['reps'].toInt(),
        this.sets = json['sets'].toInt(),
        this.secsUp = json['secsUp'],
        this.secsDown = json['secsDown'],
        this.secsRest = json['secsRest'],
        this.secsStart = json['secsStart'],
        this.upFirst = json['upFirst'],
        this.key = json['key'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'reps': reps,
        'sets': sets,
        'secsUp': secsUp,
        'secsDown': secsDown,
        'secsRest': secsRest,
        'secsStart': secsStart,
        'upFirst': upFirst,
        'key': key.toString()
      };

  bool get downFirst {
    return !upFirst;
  }

  num get secsActive {
    // var extra;
    // if (upFirst)
    //   extra = secsDown;
    // else
    //   extra = secsUp;
    return reps * (secsUp + secsDown);
  }

  num get duration {
    return (sets * secsStart + sets * secsActive + (sets - 1) * secsRest);
  }

  List<num> get durations {
    if (_durations.isEmpty) {
      for (var i = 0; i < sets - 1; i++) {
        _durations.add(secsStart);
        _durations.add(secsActive);
        _durations.add(secsRest);
      }
      _durations.add(secsStart);
      _durations.add(secsActive);
    }
    return _durations;
  }

  List<ExercisePhase> get phases {
    if (_phases.isEmpty) {
      for (var i = 0; i < sets - 1; i++) {
        _phases.add(ExercisePhase.ready);
        _phases.add(ExercisePhase.active);
        _phases.add(ExercisePhase.rest);
      }
      _phases.add(ExercisePhase.ready);
      _phases.add(ExercisePhase.active);
    }
    return _phases;
  }

  List<int> get setNums {
    if (_setNums.isEmpty) {
      for (var i = 1; i < sets; i++) {
        _setNums.add(i);
        _setNums.add(i);
        _setNums.add(i);
      }
      _setNums.add(sets);
      _setNums.add(sets);
    }
    return _setNums;
  }
}

enum ExercisePhase { ready, active, rest, end }

extension NumberParsing on num {
  String pluralString(String s) {
    if (this != 1)
      return this.toString() + ' ' + s + 's';
    else
      return this.toString() + ' ' + s;
  }

  String minutesSeconds() {
    Duration duration = Duration(seconds: this.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  String cardinal() {
    if (this == 1)
      return '1st';
    else if (this == 2)
      return '2nd';
    else if (this == 3)
      return '3rd';
    else
      return this.toString() + 'th';
  }
}

extension DurationParsing on Duration {
  String minutesSeconds() {
    var res = this.toString();
    var split = res.split(':');
    res = split[1] + ':' + split[2];
    res = res.split('.')[0];
    return res;
  }
}

class TimeCounter {
  Timer timer;
  // Ticker ticker;
  Stopwatch stopwatch = Stopwatch();
  final Duration duration;
  bool running = false;
  void Function() callback;
  void Function() onTick;
  int _accumMicroseconds = 0;

  TimeCounter(this.duration, this.callback, this.onTick) {
    // ticker = Ticker((_) => onTick);
  }

  int get elapsedTicks {
    return stopwatch.elapsedTicks;
  }

  double get elapsedSeconds {
    return _elapsedMicroseconds / 1000000;
  }

  int get _elapsedMicroseconds {
    var res = stopwatch.elapsedMicroseconds + _accumMicroseconds;
    if (res > duration.inMicroseconds)
      return duration.inMicroseconds;
    else
      return res;
  }

  // set elapsedSeconds(num seconds) {
  //   stopwatch.reset();
  //   _accumMicroseconds = (seconds * 1000000).round();
  //   if (running) {
  //     timer = Timer(
  //         Duration(
  //             microseconds: duration.inMicroseconds - _elapsedMicroseconds),
  //         end);
  //   }
  // }

  void start() {
    timer = Timer(
        Duration(microseconds: duration.inMicroseconds - _elapsedMicroseconds),
        end);
    // ticker.start();
    stopwatch.start();
    running = true;
  }

  void reset() {
    stopwatch.reset();
    if (timer != null) timer.cancel();
    if (running)
      timer = Timer(
          Duration(
              microseconds: duration.inMicroseconds - _elapsedMicroseconds),
          end);
  }

  void stop() {
    stopwatch.stop();
    // ticker.stop();
    if (timer != null) timer.cancel();
    running = false;
  }

  void end() {
    callback();
    stop();
  }
}

class ExerciseTimer {
  Exercise exercise;
  int index = 0;
  // num accumSeconds = 0;
  bool playing = false;
  bool ended = false;
  final List<TimeCounter> timers = [];
  void Function() tickerCallback;
  Metronome metronome;
  ReadyBeeper readyBeeper;
  RestBeeper restBeeper;
  final void Function() doWhenMoveDown;
  final void Function() doWhenMoveUp;
  final void Function() doWhenRest;

  get accumSeconds {
    return index == 0
        ? 0
        : exercise._durations
            .sublist(0, index)
            .reduce((value, element) => value + element);
  }

  ExerciseTimer(this.exercise, this.tickerCallback, this.doWhenMoveDown,
      this.doWhenMoveUp, this.doWhenRest) {
    for (var i = 0; i < exercise.durations.length; i++) {
      timers.add(TimeCounter(
        Duration(microseconds: (exercise.durations[i] * 1000000).round()),
        _nextTimer,
        tickerCallback,
      ));
    }
    if (exercise.upFirst)
      metronome = Metronome(
        exercise.secsUp,
        exercise.secsDown,
        exercise.reps,
        beat1: doWhenMoveDown,
        beat2: doWhenMoveUp,
        beatReset: doWhenRest,
      );
    else
      metronome = Metronome(
        exercise.secsDown,
        exercise.secsUp,
        exercise.reps,
        beat1: doWhenMoveUp,
        beat2: doWhenMoveDown,
        beatReset: doWhenRest,
      );
    readyBeeper = ReadyBeeper(exercise.secsStart.toDouble());
    restBeeper = RestBeeper(exercise.secsRest.toDouble());
  }

  void play() {
    assert(!ended, 'Exercise timer ended, must reset before starting.');
    timers[index].start();
    playing = true;
    if (exercise.phases[index] == ExercisePhase.active)
      metronome.start();
    else if (exercise.phases[index] == ExercisePhase.ready)
      readyBeeper.start();
    else if (exercise.phases[index] == ExercisePhase.rest) restBeeper.start();
  }

  void pause() {
    if (index < timers.length) timers[index].stop();
    metronome.stop();
    readyBeeper.stop();
    restBeeper.stop();
    playing = false;
  }

  void _nextTimer() {
    if (index < timers.length) {
      timers[index].stop();
      timers[index].reset();
      metronome.stop();
      metronome.reset();
      readyBeeper.stop();
      readyBeeper.reset();
      restBeeper.stop();
      restBeeper.reset();
      index++;
    }
    if (index < timers.length) {
      if (!playing) return;
      timers[index].start();
      if (exercise.phases[index] == ExercisePhase.active)
        metronome.start();
      else if (exercise.phases[index] == ExercisePhase.ready)
        readyBeeper.start();
      else if (exercise.phases[index] == ExercisePhase.rest) restBeeper.start();
    } else {
      ended = true;
      pause();
    }
  }

  // doens't pause
  void _resetTimer() {
    if (index < timers.length) timers[index].reset();
    metronome.reset();
    readyBeeper.reset();
    restBeeper.reset();
  }

  // resets if at first
  void _previousTimer() {
    ended = false;
    if (index < timers.length) {
      timers[index].stop();
      timers[index].reset();
      metronome.stop();
      metronome.reset();
      readyBeeper.stop();
      readyBeeper.reset();
      restBeeper.stop();
      restBeeper.reset();
    }
    // } else {
    //   ended = false;
    // }
    if (index > 0) index--;
    if (playing) {
      timers[index].start();
      if (exercise.phases[index] == ExercisePhase.active)
        metronome.start();
      else if (exercise.phases[index] == ExercisePhase.ready)
        readyBeeper.start();
      else if (exercise.phases[index] == ExercisePhase.rest) restBeeper.start();
    }
  }

  void skipNext() {
    _nextTimer();
  }

  void skipPrevious() {
    if (index < timers.length && timers[index].elapsedSeconds > 2)
      _resetTimer();
    else
      _previousTimer();
  }

  num get elapsedSubSeconds {
    if (index == timers.length)
      return exercise.durations.last;
    else
      return timers[index].elapsedSeconds;
  }

  num get elapsedSeconds {
    if (index == timers.length)
      return accumSeconds;
    else {
      var res = accumSeconds + timers[index].elapsedSeconds;
      if (res > exercise.duration) {
        return exercise.duration;
      } else {
        return res;
      }
    }
  }

  void cancel() {
    index = 0;
    playing = false;
    ended = true;
    for (var i = 0; i < timers.length; i++) {
      timers[i].stop();
      timers[i].reset();
    }
    metronome.stop();
    metronome.reset();
    readyBeeper.stop();
    readyBeeper.reset();
    restBeeper.stop();
    restBeeper.reset();
  }
}

abstract class SoundTicker {
  Stopwatch stopwatch;
  bool running;
  void start();
  void stop();
  void reset();
  void setUpPlayers();
}

class Metronome implements SoundTicker {
  final num dur1;
  final num dur2;
  final int totalCycles;
  int _currentCycle = 0;
  Stopwatch stopwatch = Stopwatch();
  num duration;
  Timer timer1;
  Timer timer2;
  Timer timerFinish;
  bool running = false;
  bool _playersSetUp = false;
  void Function() beat1;
  void Function() beat2;
  void Function() beatReset;

  Metronome(this.dur1, this.dur2, this.totalCycles,
      {this.beat1, this.beat2, this.beatReset}) {
    duration = totalCycles * (dur1 + dur2);
    if (beat1 == null) {
      beat1 = () {};
    }
    if (beat2 == null) {
      beat2 = () {};
    }
    if (beatReset == null) {
      beatReset = () {};
    }
  }

  // if using just_audio
  final audioPlayer1 = AudioPlayer(handleInterruptions: true);
  final audioPlayer2 = AudioPlayer(handleInterruptions: true);
  final audioPlayerFinish = AudioPlayer(handleInterruptions: true);

  void setUpPlayers() async {
    if (!_playersSetUp) {
      await audioPlayer1.setAsset('assets/notification_high-intensity.wav');
      await audioPlayer2.setAsset('assets/notification_decorative-01.wav');
      await audioPlayerFinish.setAsset('assets/hero_simple-celebration-03.wav');
      await audioPlayer1.setVolume(3);
      await audioPlayer2.setVolume(3);
      await audioPlayerFinish.setVolume(3);
      _playersSetUp = true;
    }
  }

  // // if using sounds
  // Track tick1 = Track.fromAsset('assets/woodblock.mp3');
  // Track tick2 = Track.fromAsset('assets/drumsticks.mp3');
  // Track tickFinish = Track.fromAsset('assets/hero_simple-celebration-03.wav');

  void start() {
    print('Metronome started');
    setUpPlayers();
    running = true;
    var time = stopwatch.elapsedMicroseconds / 1000000;
    time = time % (dur1 + dur2);
    stopwatch.start();
    if (time == 0) {
      _beat2();
    }
    if (time <= dur1) {
      _startTimer1(skip: time);
    } else {
      _startTimer2(skip: time - dur1);
    }
  }

  void stop() async {
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();
    stopwatch.stop();
    running = false;
    await AudioSession.instance
        .then((session) async => await session.setActive(false));
    print('Metronome stopped');
  }

  void reset() {
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();
    stopwatch.reset();
    _currentCycle = 0;
    beatReset();
    print('Metronome reset');
    if (running) {
      var time = stopwatch.elapsedMicroseconds / 1000000;
      time = time % (dur1 + dur2);
      if (time == 0) {
        _beat2();
      }
      if (time <= dur1) {
        _startTimer1(skip: time);
      } else {
        _startTimer2(skip: time - dur1);
      }
    }
  }

  void _startTimer1({num skip = 0}) {
    if (_currentCycle < totalCycles)
      timer1 = Timer(Duration(microseconds: ((dur1 - skip) * 1000000).round()),
          _callback1);
    else {
      stop();
      reset();
    }
  }

  void _startTimer2({num skip = 0}) {
    if (_currentCycle < totalCycles - 1)
      timer2 = Timer(Duration(microseconds: ((dur2 - skip) * 1000000).round()),
          _callback2);
    else if (_currentCycle == totalCycles - 1)
      timerFinish = Timer(
          Duration(microseconds: ((dur2) * 1000000).round()), _beatFinish);
    else {
      stop();
      reset();
    }
  }

  void _callback1() {
    _beat1();
    _startTimer2();
  }

  void _callback2() {
    _beat2();
    _currentCycle = _currentCycle + 1;
    _startTimer1();
  }

  void _beat1() {
    print('beat1');
    // if using just_audio
    audioPlayer1.seek(Duration(microseconds: 0));
    audioPlayer1.play().then((_) => audioPlayer1.stop());
    // // if using sounds
    // QuickPlay.fromTrack(tick1);
    beat1();
  }

  void _beat2() {
    print('beat2');
    // if usign just audio
    audioPlayer2.seek(Duration(microseconds: 0));
    audioPlayer2.play().then((_) => audioPlayer2.stop());
    // // if using sounds
    // QuickPlay.fromTrack(tick2);
    beat2();
  }

  void _beatFinish() {
    print('beatFinish');
    // if using just_audio
    audioPlayerFinish.seek(Duration(microseconds: 0));
    audioPlayerFinish.play().then((_) => audioPlayerFinish.stop2());

    // audioPlayerFinish.dispose();
    // audioPlayer1.dispose();
    // audioPlayer2.dispose();
    // // if using sounds
    // QuickPlay.fromTrack(tickFinish);
  }
}

class ReadyBeeper implements SoundTicker {
  @override
  Stopwatch stopwatch = Stopwatch();
  final double duration;
  final double shortDuration;
  final double endDuration;
  double longDuration;
  Timer longTimer;
  Timer shortTimer;
  int currentIndex = 0;
  bool running;
  bool _playersSetUp = false;

  ReadyBeeper(this.duration, {this.shortDuration = 1.0, this.endDuration = 1}) {
    longDuration = duration - endDuration - shortDuration * 2;
  }

  final List<AudioPlayer> audioPlayers = [
    AudioPlayer(handleInterruptions: false),
    AudioPlayer(handleInterruptions: false),
    AudioPlayer(handleInterruptions: false)
  ];

  final List<String> soundAssets = [
    'assets/notification_high-intensity.wav',
    'assets/notification_high-intensity.wav',
    'assets/notification_decorative-01.wav'
  ];

  @override
  void setUpPlayers() async {
    if (_playersSetUp) return;
    for (var i = 0; i < audioPlayers.length; i++) {
      await audioPlayers[i].setAsset(soundAssets[i]);
      await audioPlayers[i].setVolume(3);
    }
    _playersSetUp = true;
  }

  @override
  void start() {
    setUpPlayers();
    running = true;
    var time = stopwatch.elapsedMicroseconds / 1000000;
    stopwatch.start();
    if (time < longDuration) {
      _startLongTimer(skip: time);
    } else {
      time = (time - longDuration) % shortDuration;
      _startShortTimer(skip: time);
    }
  }

  @override
  void stop() async {
    if (shortTimer != null) shortTimer.cancel();
    if (longTimer != null) longTimer.cancel();
    stopwatch.stop();
    running = false;
    await AudioSession.instance
        .then((session) async => await session.setActive(false));
  }

  @override
  void reset() {
    if (shortTimer != null) shortTimer.cancel();
    if (longTimer != null) longTimer.cancel();
    stopwatch.reset();
    currentIndex = 0;
    if (running) _startLongTimer();
  }

  _startLongTimer({double skip = 0}) {
    longTimer = Timer(
        Duration(microseconds: ((longDuration - skip) * 1000000).round()),
        _callback);
  }

  _startShortTimer({double skip = 0}) {
    if (currentIndex == 3) {
      stop();
      reset();
      return;
    }
    shortTimer = Timer(
        Duration(microseconds: ((shortDuration - skip) * 1000000).round()),
        _callback);
  }

  void _callback() {
    _beat();
    currentIndex = currentIndex + 1;
    _startShortTimer();
  }

  void _beat() {
    audioPlayers[currentIndex].seek(Duration(microseconds: 0));
    audioPlayers[currentIndex]
        .play()
        .then((_) => audioPlayers[currentIndex].stop2());
  }
}

class RestBeeper implements SoundTicker {
  @override
  bool running;

  @override
  Stopwatch stopwatch = Stopwatch();
  Timer timer;

  final double duration;
  final double endDuration;
  double timerDuration;
  bool _setUpPlayer = false;
  bool _hasBeat = false;

  RestBeeper(this.duration, {this.endDuration = 0.5}) {
    timerDuration = duration - endDuration;
  }

  AudioPlayer audioPlayer = AudioPlayer(handleInterruptions: false);

  String soundAsset = 'assets/hero_decorative-celebration-01.wav';

  @override
  void setUpPlayers() async {
    if (_setUpPlayer) return;
    await audioPlayer.setAsset(soundAsset);
    await audioPlayer.setVolume(3);
    _setUpPlayer = true;
  }

  @override
  void start() {
    setUpPlayers();
    running = true;
    var time = stopwatch.elapsedMicroseconds / 1000000;
    stopwatch.start();
    _startTimer(skip: time);
  }

  @override
  void stop() async {
    if (timer != null) timer.cancel();
    running = false;
    stopwatch.stop();
    await AudioSession.instance
        .then((session) async => await session.setActive(false));
  }

  @override
  void reset() {
    if (timer != null) timer.cancel();
    stopwatch.reset();
    _hasBeat = false;
    if (running) {
      _startTimer();
    }
  }

  void _startTimer({double skip = 0}) {
    if (_hasBeat) {
      stop();
      reset();
      return;
    }
    timer = Timer(
        Duration(microseconds: ((timerDuration - skip) * 1000000).round()),
        _callback);
  }

  void _callback() {
    _beat();
    _hasBeat = true;
  }

  void _beat() {
    audioPlayer.seek(Duration(milliseconds: 0));
    audioPlayer.play().then((_) => audioPlayer.stop2());
  }
}

enum RepState { up, down, rest, ready, end }

extension ProperStopping on AudioPlayer {
  Future<void> stop2() async {
    this.stop();
    await AudioSession.instance
        .then((session) async => await session.setActive(false));
  }
}
