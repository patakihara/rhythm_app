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
import 'package:shared_preferences/shared_preferences.dart';
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
    var getDirectory = getApplicationDocumentsDirectory();
    getDirectory.onError((error, stackTrace) {
      fetchDefault();
    });
    getDirectory.then((Directory directory) async {
      if (await directory.exists()) {
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
          return;
        }
      }
      fetchDefault();
    });
  }

  void fetchDefault() {
    print("File or directory does not exist!");
    if (T == Exercise) {
      var objects = <Exercise>[];
      objects.add(Exercise(name: 'Sit ups'));
      objects.add(Exercise(name: 'Biceps curl'));
      objects.add(Exercise(name: 'Pull ups'));
      objects.add(Exercise(name: 'Squats'));
      var decodedMap = DataMap<Exercise>.fromObjects(objects);
      dataMap.addAll(decodedMap);
      library.getExercisesFromStorage();
    } else if (T == Plan) {
      var objects = <Plan>[];
      objects.add(Plan.fromList(
          'Upper body 1', <String>['Pull ups', 'Sit ups', 'Biceps curl']));
      objects.add(Plan.fromList(
          'Lower body 1', <String>['Pull ups', 'Sit ups', 'Squats']));
      var decodedMap = DataMap<Plan>.fromObjects(objects);
      dataMap.addAll(decodedMap);
      library.getPlansFromStorage();
    }
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

  Duration _duration;

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

  // num get secsActive {
  //   // var extra;
  //   // if (upFirst)
  //   //   extra = secsDown;
  //   // else
  //   //   extra = secsUp;
  //   return reps * (secsUp + secsDown) + 2;
  // }

  Duration get duration {
    if (_duration != null) return _duration;
    _duration = ExerciseDurations.whole(
        reps, sets, secsUp, secsDown, secsRest, secsStart);
    return _duration;
  }

  // List<num> get durations {
  //   if (_durations.isEmpty) {
  //     for (var i = 0; i < sets - 1; i++) {
  //       _durations.add(secsStart);
  //       _durations.add(secsActive);
  //       _durations.add(secsRest);
  //     }
  //     _durations.add(secsStart);
  //     _durations.add(secsActive);
  //   }
  //   return _durations;
  // }

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

class ExerciseDurations {
  static Duration whole(int reps, int sets, num secsUp, num secsDown,
      num secsRest, num secsStart) {
    var result = Duration.zero;
    result += readyBeeper(secsStart.toDuration());
    result += metronome(reps, secsUp.toDuration(), secsDown.toDuration());
    for (var i = 0; i < sets - 1; i++) {
      result += restBeeper(secsRest.toDuration());
      result += readyBeeper(secsStart.toDuration());
      result += metronome(reps, secsUp.toDuration(), secsDown.toDuration());
    }
    return result;
  }

  static Duration metronome(int numCycles, Duration ticTime, Duration tocTime) {
    Duration result = Duration.zero;
    result += metronomeStartDuration;
    for (var i = 0; i < numCycles - 1; i++) {
      result += ticTime + tocTime;
    }
    result += ticTime;
    result += finishDuration;
    result += metronomeEndDuration;
    return result;
  }

  static Duration readyBeeper(Duration duration) => duration;

  static Duration restBeeper(Duration duration) => duration;

  /// [Metronome] durations
  static Duration metronomeStartDuration = Duration(milliseconds: 1000);
  static Duration tictocDuration = Duration(milliseconds: 600);
  static Duration finishDuration = Duration(milliseconds: 1428);
  static Duration metronomeEndDuration = Duration(milliseconds: 500);

  /// [ReadyBeeper] durations
  static Duration readyBeeperEndDuration = Duration(milliseconds: 100);
  static Duration shortBeepDuration = Duration(milliseconds: 1288);
  static Duration longBeepDuration = Duration(milliseconds: 1560);

  /// [RestBeeper] durations
  static Duration restBeeperEndDuration = Duration(milliseconds: 100);
  static Duration beepDuration = Duration(milliseconds: 2000);
}

enum ExercisePhase { ready, active, rest, end }

extension NumberParsing on num {
  Duration toDuration() => Duration(microseconds: (this * 1000000).round());

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

class ExerciseTimer extends ChangeNotifier {
  final Exercise exercise;
  final int numBeepers;

  Metronome metronome;
  ReadyBeeper readyBeeper;
  RestBeeper restBeeper;
  final void Function() doAfterToc;
  final void Function() doAfterTic;
  final void Function() doWhenRest;

  int _index = 0;
  bool _playing = false;
  bool _ended = false;

  int get index => _index;
  bool get playing => _playing;
  bool get ended => _ended;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  set playing(bool value) {
    _playing = value;
    notifyListeners();
  }

  set ended(bool value) {
    _ended = value;
    notifyListeners();
  }

  ExercisePhase get currentPhase => exercise.phases[index];

  Beeper get currentBeeper {
    return beeperAt(index);
  }

  Beeper beeperAt(int i) {
    if (exercise.phases[i] == ExercisePhase.active)
      return metronome;
    else if (exercise.phases[i] == ExercisePhase.ready)
      return readyBeeper;
    else if (exercise.phases[i] == ExercisePhase.rest)
      return restBeeper;
    else
      return null;
  }

  ExerciseTimer(this.exercise,
      {this.doAfterToc, this.doAfterTic, this.doWhenRest})
      : numBeepers = exercise.phases.length {
    metronome = Metronome(
      Duration(milliseconds: (exercise.secsUp * 1000).round()),
      Duration(milliseconds: (exercise.secsDown * 1000).round()),
      exercise.reps,
      onToc: doAfterToc,
      onTic: doAfterTic,
      onReset: doWhenRest,
      onEnd: _nextTimer,
    );
    readyBeeper = ReadyBeeper(
      Duration(milliseconds: (exercise.secsStart * 1000).round()),
      onEnd: _nextTimer,
    );
    restBeeper = RestBeeper(
      Duration(milliseconds: (exercise.secsRest * 1000).round()),
      onEnd: _nextTimer,
    );
  }

  Duration get position {
    var result = Duration.zero;
    for (var i = 0; i < index; i++) {
      result += beeperAt(i).duration;
    }
    result += currentBeeper.position ?? Duration.zero;
    return result;
  }

  Duration get duration {
    var result = Duration.zero;
    for (var i = 0; i < numBeepers; i++) {
      result += beeperAt(i).duration;
    }
    return result;
  }

  double get progress => (position.inMilliseconds / duration.inMilliseconds)
      .toDouble()
      .clamp(0.0, 1.0);

  Duration get subPosition => currentBeeper.position;

  Duration get subDuration => currentBeeper.duration;

  double get subProgress => currentBeeper.progress;

  int get currentRep {
    if (currentBeeper is Metronome)
      return metronome.currentCycle;
    else
      return 0;
  }

  void play() {
    assert(!ended, 'Exercise timer ended, must reset before starting.');
    playing = true;
    print('exercise timer playing');
    currentBeeper.play();
    notifyListeners();
  }

  void pause() {
    currentBeeper.pause();
    playing = false;
    notifyListeners();
  }

  void _nextTimer() {
    if (index == numBeepers - 1) {
      pause();
      ended = true;
    } else if (index < numBeepers - 1) {
      currentBeeper.pause();
      currentBeeper.reset();
      index++;
    }
    if (index < numBeepers) {
      if (!playing) return;
      currentBeeper.play();
    }
    notifyListeners();
  }

  // doens't pause
  void _resetTimer() {
    currentBeeper.reset();
    notifyListeners();
  }

  // resets if at first
  void _previousTimer() {
    ended = false;
    if (index < numBeepers) {
      currentBeeper.pause();
      currentBeeper.reset();
    }
    // } else {
    //   ended = false;
    // }
    if (index > 0) index--;
    if (playing) {
      currentBeeper.play();
    }
    notifyListeners();
  }

  void skipNext() {
    _nextTimer();
  }

  void skipPrevious() {
    if (index < numBeepers && currentBeeper.position > Duration(seconds: 2))
      _resetTimer();
    else
      _previousTimer();
  }

  @override
  void dispose() {
    index = 0;
    playing = false;
    ended = true;
    currentBeeper.pause();
    currentBeeper.reset();
    metronome.dispose();
    readyBeeper.dispose();
    restBeeper.dispose();
    notifyListeners();
    removeListener(() {});
    super.dispose();
  }
}

abstract class Beeper {
  bool get running => _running;

  Duration get duration =>
      durations.reduce((value, element) => value + element);

  Duration get position {
    if (disposed) return duration;
    return (audioIndex > 0
            ? durations
                .sublist(0, audioIndex)
                .reduce((value, element) => value + element)
            : Duration.zero) +
        (audioPlayer.position ?? Duration.zero);
  }

  double get progress => (position.inMicroseconds / duration.inMicroseconds)
      .toDouble()
      .clamp(0, 1)
      .toDouble();

  AudioPlayer audioPlayer;

  final void Function() onEnd;
  final void Function() onReset;

  bool _playerSetUp = false;
  bool _sourcesSetUp = false;

  bool _running = false;

  StreamSubscription<ProcessingState> _playerStateSubscription;

  int get audioIndex => audioPlayer.currentIndex;
  int get audioLength => audioSources.length;

  List<AudioSource> get audioSources {
    setUpSources();
    return _audioSources;
  }

  final List<AudioSource> _audioSources = <AudioSource>[];

  List<Duration> get durations {
    setUpSources();
    return _durations;
  }

  final List<Duration> _durations = <Duration>[];

  Beeper({
    void Function() onReset,
    void Function() onEnd,
  })  : this.onReset = onReset ?? (() {}),
        this.onEnd = onEnd ?? (() {}) {
    setUpSources();
    setUpPlayer();
    setUpSubscription();
  }

  void getPlayer() async {
    if (audioPlayer != null) return;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final duckAudio = preferences.getBool('duckAudio') ?? false;

    audioPlayer = AudioPlayer(
      handleInterruptions: false,
      handleAudioSessionActivation: duckAudio,
      androidApplyAudioAttributes: duckAudio,
    );
  }

  void setUpPlayer() async {
    if (_playerSetUp) return;

    getPlayer();

    await audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: audioSources,
        useLazyPreparation: false,
      ),
    );
    await audioPlayer.setVolume(1);

    _playerSetUp = true;
  }

  void setUpSubscription() {
    if (_playerStateSubscription != null) return;
    _playerStateSubscription =
        audioPlayer.processingStateStream.listen(stateListener);
  }

  void stateListener(ProcessingState state) {
    if (state == ProcessingState.completed) {
      audioPlayer.stop();
      _playerStateSubscription.pause();
      onEnd();
    }
  }

  void setUpSources() {
    if (_sourcesSetUp) return;
    _sourcesSetUp = true;
  }

  void play() {
    assert(!disposed, '$typeName has been disposed, cannot play');
    print('$typeName started');
    setUpPlayer();
    _running = true;
    audioPlayer.play();
  }

  void pause() async {
    assert(!disposed, '$typeName has been disposed, cannot pause');
    audioPlayer.pause();
    _running = false;
    print('$typeName stopped');
  }

  void reset() {
    assert(!disposed, '$typeName has been disposed, cannot reset');
    print('$typeName reset');
    if (progress > 0) audioPlayer.seek(Duration(seconds: 0), index: 0);
    audioPlayer.pause();
    if (running) {
      audioPlayer.play();
    }
    _playerStateSubscription.resume();
    onReset();
  }

  bool disposed = false;

  void dispose() {
    disposed = true;
    audioPlayer.stop();
    audioPlayer.dispose();
  }

  final String typeName = 'Beeper';
}

class Metronome extends Beeper {
  final Duration ticDuration;
  final Duration tocDuration;
  final int totalCycles;

  int _currentCycle = 0;
  int get currentCycle => _currentCycle;

  final void Function() onToc;
  final void Function() onTic;

  List<int> _ticIndices = [];
  List<int> _tocIndices = [];
  List<int> _finishIndices = [];

  Metronome(
    this.tocDuration,
    this.ticDuration,
    this.totalCycles, {
    void Function() onTic,
    void Function() onToc,
    void Function() onReset,
    void Function() onEnd,
  })  : this.onTic = onTic ?? (() {}),
        this.onToc = onToc ?? (() {}),
        super(onReset: onReset, onEnd: onEnd);

  @override
  void setUpPlayer() async {
    if (_playerSetUp) return;

    super.getPlayer();

    await audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: audioSources,
        useLazyPreparation: false,
      ),
    );
    await audioPlayer.setVolume(1);

    audioPlayer.currentIndexStream.listen((index) {
      doWhenIndex(index);
    });

    _playerSetUp = true;
  }

  @override
  void setUpSources() {
    if (_sourcesSetUp) return;

    final startDur = ExerciseDurations.metronomeStartDuration;
    final tictocDur = ExerciseDurations.tictocDuration;
    final finishDur = ExerciseDurations.finishDuration;
    final endDur = ExerciseDurations.metronomeEndDuration;

    final ticSource =
        AudioSource.uri(Uri.parse('asset:///assets/drumsticks.mp3'));
    final tocSource =
        AudioSource.uri(Uri.parse('asset:///assets/woodblock.mp3'));
    final silenceSource =
        AudioSource.uri(Uri.parse('asset:///assets/silence.mp3'));
    final finishSource = AudioSource.uri(
        Uri.parse('asset:///assets/hero_simple-celebration-03.wav'));

    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: startDur,
      ),
    );
    _durations.add(startDur);

    for (var i = 0; i < totalCycles - 1; i++) {
      _ticIndices.add(_audioSources.length);
      _audioSources.add(
        ClippingAudioSource(
          child: ticSource,
          end: tictocDur,
        ),
      );
      _durations.add(tictocDur);

      _audioSources.add(
        ClippingAudioSource(
          child: silenceSource,
          end: ticDuration - tictocDur,
        ),
      );
      _durations.add(ticDuration - tictocDur);

      _tocIndices.add(_audioSources.length);
      _audioSources.add(
        ClippingAudioSource(
          child: tocSource,
          end: tictocDur,
        ),
      );
      _durations.add(tictocDur);

      _audioSources.add(
        ClippingAudioSource(
          child: silenceSource,
          end: tocDuration - tictocDur,
        ),
      );
      _durations.add(tocDuration - tictocDur);
    }

    _ticIndices.add(_audioSources.length);
    _audioSources.add(
      ClippingAudioSource(
        child: ticSource,
        end: tictocDur,
      ),
    );
    _durations.add(tictocDur);

    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: ticDuration - tictocDur,
      ),
    );
    _durations.add(ticDuration - tictocDur);

    _tocIndices.add(_audioSources.length);
    _audioSources.add(
      ClippingAudioSource(
        child: finishSource,
        end: finishDur,
      ),
    );
    _durations.add(finishDur);

    _finishIndices.add(_audioSources.length);
    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: endDur,
      ),
    );
    _durations.add(endDur);

    _sourcesSetUp = true;
  }

  int _lastIndex = -1;

  void doWhenIndex(index) {
    if (_lastIndex != index) {
      if (_ticIndices.contains(index)) {
        onTic();
      } else if (_tocIndices.contains(index)) {
        onToc();
        _currentCycle++;
      }
      if (_finishIndices.contains(index)) {
        _currentCycle++;
      }
      _lastIndex = index;
    }
  }

  @override
  void reset() {
    super.reset();
    _currentCycle = 0;
  }

  @override
  final String typeName = 'Metronome';
}

class ReadyBeeper extends Beeper {
  final Duration inputDuration;

  ReadyBeeper(Duration duration, {void Function() onEnd})
      : this.inputDuration = duration,
        super(onEnd: onEnd);

  @override
  void setUpSources() {
    if (_sourcesSetUp) return;

    final Duration endDur = ExerciseDurations.readyBeeperEndDuration;
    final Duration shortDur = ExerciseDurations.shortBeepDuration;
    final Duration longDur = ExerciseDurations.longBeepDuration;
    final Duration startDur = inputDuration - shortDur * 2 - longDur - endDur;

    final silenceSource =
        AudioSource.uri(Uri.parse('asset:///assets/silence.mp3'));
    final shortSource = AudioSource.uri(
        Uri.parse('asset:///assets/notification_high-intensity.wav'));
    final longSource = AudioSource.uri(
        Uri.parse('asset:///assets/notification_decorative-01.wav'));

    _durations.add(startDur);
    _durations.add(shortDur);
    _durations.add(shortDur);
    _durations.add(longDur);
    _durations.add(endDur);

    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: startDur,
      ),
    );
    _audioSources.add(
      ClippingAudioSource(
        child: shortSource,
        end: shortDur,
      ),
    );
    _audioSources.add(
      ClippingAudioSource(
        child: shortSource,
        end: shortDur,
      ),
    );
    _audioSources.add(
      ClippingAudioSource(
        child: longSource,
        end: longDur,
      ),
    );
    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: endDur,
      ),
    );
    _sourcesSetUp = true;
  }

  final String typeName = 'ReadyBeeper';
}

class RestBeeper extends Beeper {
  String soundAsset = 'assets/hero_decorative-celebration-01.wav';

  final Duration inputDuration;

  RestBeeper(Duration duration, {void Function() onEnd})
      : this.inputDuration = duration,
        super(onEnd: onEnd);

  @override
  void setUpSources() {
    if (_sourcesSetUp) return;

    final Duration endDur = ExerciseDurations.restBeeperEndDuration;
    final Duration beepDur = ExerciseDurations.beepDuration;
    final Duration startDur = inputDuration - beepDur - endDur;

    final silenceSource =
        AudioSource.uri(Uri.parse('asset:///assets/silence.mp3'));
    final beepSource = AudioSource.uri(
        Uri.parse('asset:///assets/hero_decorative-celebration-01.wav'));

    _durations.add(startDur);
    _durations.add(beepDur);
    _durations.add(endDur);

    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: startDur,
      ),
    );
    _audioSources.add(
      ClippingAudioSource(
        child: beepSource,
        end: beepDur,
      ),
    );
    _audioSources.add(
      ClippingAudioSource(
        child: silenceSource,
        end: endDur,
      ),
    );
    _sourcesSetUp = true;
  }

  final String typeName = 'RestBeeper';
}

enum RepState { up, down, rest, ready, end }

// extension ProperStopping on AudioPlayer {

//   static AudioPlayer silentPlayer = AudioPlayer(handleAudioSessionActivation: )

//   Future<void> play2() async {

//   }

//   Future<void> stop2() async {
//     this.stop();
//     await AudioSession.instance
//         .then((session) async => await session.setActive(false));
//   }
// }
