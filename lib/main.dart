import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'home_page.dart';
import 'classes.dart';
import 'providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'themes.dart';

// final NowPlaying player = NowPlaying();

// void _myEntrypoint() =>
//     AudioServiceBackground.run(() => BackgroundPlayer(nowPlaying));

// class ServiceStarter {
//   static void startService() async {
//     print('Starting audio service');
//     await AudioService.connect();
//     await AudioService.start(
//       backgroundTaskEntrypoint: _myEntrypoint,
//       androidNotificationIcon: 'mipmap/ic_launcher',
//     );
//   }
// }

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NowPlaying nowPlaying = NowPlaying();
  final MenuProvider menuProvider = MenuProvider();

  void configureAudio() async {
    AudioSession.instance.then((session) async {
      await session.configure(AudioSessionConfiguration(
          // avAudioSessionCategory: AVAudioSessionCategory.ambient,
          // avAudioSessionCategoryOptions:
          //     AVAudioSessionCategoryOptions.allowBluetooth,
          // avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          // avAudioSessionRouteSharingPolicy:
          //     AVAudioSessionRouteSharingPolicy.independent,
          // avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.unknown,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: false));
    });
  }

  // void handleInterruptions(AudioSession session) {
  //   session.interruptionEventStream.listen((event) {
  //     if (event.begin) {
  //       switch (event.type) {
  //         case AudioInterruptionType.duck:
  //           // Another app started playing audio and we should duck.
  //           break;
  //         case AudioInterruptionType.pause:
  //           break;
  //         case AudioInterruptionType.unknown:
  //           // Another app started playing audio and we should pause.
  //           break;
  //       }
  //     } else {
  //       switch (event.type) {
  //         case AudioInterruptionType.duck:
  //           // The interruption ended and we should unduck.
  //           break;
  //         case AudioInterruptionType.pause:
  //           break;
  //         // The interruption ended and we should resume.
  //         case AudioInterruptionType.unknown:
  //           // The interruption ended but we should not resume.
  //           break;
  //       }
  //     }
  //   });
  // }

  void setUpMediaNotifications() {
    MediaNotification.setListener('play', () {
      setState(() {
        nowPlaying.play();
      });
    });
    MediaNotification.setListener('pause', () {
      setState(() {
        nowPlaying.pause();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    configureAudio();
    setUpMediaNotifications();
    menuProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<Library>(
          create: (_) => Library(),
        ),
        provider.ChangeNotifierProvider.value(
          value: this.nowPlaying,
        ),
        provider.ChangeNotifierProvider.value(
          value: this.nowPlaying.progress,
        ),
        provider.ChangeNotifierProvider.value(
          value: this.menuProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Rhythm',
        theme: menuProvider.flippedTheme ? AppTheme.dark() : AppTheme.light(),
        darkTheme:
            menuProvider.flippedTheme ? AppTheme.light() : AppTheme.dark(),
        home: HomePage(),
      ),
    );
  }
}

class MyMaterialApp extends StatefulWidget {
  MyMaterialApp({Key key}) : super(key: key);

  @override
  _MyMaterialAppState createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'Rhythm',
        theme: context.watch<MenuProvider>().flippedTheme
            ? AppTheme.dark()
            : AppTheme.light(),
        darkTheme: context.watch<MenuProvider>().flippedTheme
            ? AppTheme.light()
            : AppTheme.dark(),
        home: HomePage(),
      ),
    );
  }
}
