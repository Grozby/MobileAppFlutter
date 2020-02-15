import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/screens/landing_screen.dart';
import 'package:ryfy/widgets/general/audio_widget.dart';

class MockAuthenticationProvider extends Mock
    implements AuthenticationProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();


  final List<MethodCall> log = <MethodCall>[];
  MethodChannel('flutter.baseflow.com/permissions/methods')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'requestPermissions':
        return {7:2};
      default:
        return null;
    }
  });
  MethodChannel('flutter_sound')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    switch (methodCall.method) {
      case 'isEncoderSupported':
      case 'isDecoderSupported':
        return true;
      case 'setDbPeakLevelUpdate':
      case 'setDbLevelEnabled':
      case 'setVolume':
      case 'setSubscriptionDuration':
      case 'startPlayer':
        return "OK";
      case 'startRecorder':
        return "./test/widget_test/placeholder_file.aac";
      case 'hasPermissions':
        return true;
      case 'updateRecorderProgress':
        return {"currentPosition": 0};
      case 'seekToPlayer':
        return "";

      default:
        return null;
    }
  });

  MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getTemporaryDirectory':
        return "Bella";
      default:
        return null;
    }
  });

  MethodChannel('flutter_ffmpeg')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getFFmpegVersion':
      case 'getPlatform':
      case 'getPackageName':
        return null;
      case 'getMediaInformation':
        return {"duration": 2000.0};
      default:
        return null;
    }
  });

  testWidgets('Audio widget starting to recording', (WidgetTester tester) async {
    initializeDateFormatting();
    StreamController controller = StreamController.broadcast();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioWidget(
            audioFilePath: "Test.aac",
            notifier: controller.stream,
          ),
        ),
      ),
    ));

    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("RecordButton")));
    await tester.pump();

    expect(find.byKey(ValueKey("StopButton")), findsOneWidget);

    controller.close();
  });

  testWidgets('Audio widget start, record and stop', (WidgetTester tester) async {
    initializeDateFormatting();
    StreamController controller = StreamController.broadcast();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioWidget(
            audioFilePath: "Test.aac",
            notifier: controller.stream,
          ),
        ),
      ),
    ));

    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("RecordButton")));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pump();

    expect(find.byKey(ValueKey("StopButton")), findsOneWidget);
    expect(find.byKey(ValueKey("RecordButton")), findsNothing);

    await tester.tap(find.byKey(ValueKey("StopButton")));
    await tester.pump();
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byKey(ValueKey("StopButton")), findsNothing);
    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    controller.close();
  });

  testWidgets('Audio widget start, recording, and stopped by parent', (WidgetTester tester) async {
    initializeDateFormatting();
    StreamController controller = StreamController.broadcast();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioWidget(
            audioFilePath: "Test.aac",
            notifier: controller.stream,
          ),
        ),
      ),
    ));

    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("RecordButton")));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pump();

    expect(find.byKey(ValueKey("StopButton")), findsOneWidget);
    expect(find.byKey(ValueKey("RecordButton")), findsNothing);

    controller.sink.add(false);
    await tester.pump();
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byKey(ValueKey("StopButton")), findsNothing);
    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    controller.close();
  });

  testWidgets('Audio widget has recorded, then start player', (WidgetTester tester) async {
    initializeDateFormatting();
    StreamController controller = StreamController.broadcast();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioWidget(
            audioFilePath: "placeholder.aac",
            notifier: controller.stream,
          ),
        ),
      ),
    ));

    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("RecordButton")));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pump();

    expect(find.byKey(ValueKey("StopButton")), findsOneWidget);
    expect(find.byKey(ValueKey("RecordButton")), findsNothing);

    await tester.tap(find.byKey(ValueKey("StopButton")));
    await tester.pump();
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byKey(ValueKey("StopButton")), findsNothing);
    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);
    expect(find.byType(AudioPlayer), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("PlayButtonPlayer")));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byKey(ValueKey("PauseButtonPlayer")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("PauseButtonPlayer")));
    await tester.pumpAndSettle(Duration(seconds: 3));

    expect(find.byKey(ValueKey("StopButton")), findsNothing);
    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);
    expect(find.byKey(ValueKey("PauseButtonPlayer")), findsNothing);
    expect(find.byKey(ValueKey("PlayButtonPlayer")), findsOneWidget);

    controller.close();
  });

  testWidgets('Audio widget has recorded, start playing, then dismiss', (WidgetTester tester) async {
    initializeDateFormatting();
    StreamController controller = StreamController.broadcast();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioWidget(
            audioFilePath: "placeholder.aac",
            notifier: controller.stream,
          ),
        ),
      ),
    ));

    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("RecordButton")));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pump();

    expect(find.byKey(ValueKey("StopButton")), findsOneWidget);
    expect(find.byKey(ValueKey("RecordButton")), findsNothing);

    await tester.tap(find.byKey(ValueKey("StopButton")));
    await tester.pump();
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byKey(ValueKey("StopButton")), findsNothing);
    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);
    expect(find.byType(AudioPlayer), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("PlayButtonPlayer")));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byKey(ValueKey("PauseButtonPlayer")), findsOneWidget);

    await tester.tap(find.byKey(ValueKey("PauseButtonPlayer")));
    await tester.pumpAndSettle(Duration(seconds: 3));

    expect(find.byKey(ValueKey("StopButton")), findsNothing);
    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);
    expect(find.byKey(ValueKey("PauseButtonPlayer")), findsNothing);
    expect(find.byKey(ValueKey("PlayButtonPlayer")), findsOneWidget);


    await tester.drag(find.byKey(ValueKey("TimeToShowText")), Offset(-400, 0));
    await tester.pumpAndSettle(Duration(seconds: 2));

    expect(find.byKey(ValueKey("RecordButton")), findsOneWidget);
    expect(find.byKey(ValueKey("PauseButtonPlayer")), findsNothing);
    expect(find.byKey(ValueKey("RecordedAudio")), findsOneWidget);
    expect(find.byKey(ValueKey("PlayButtonPlayer")), findsNothing);

    controller.close();
  });
}
