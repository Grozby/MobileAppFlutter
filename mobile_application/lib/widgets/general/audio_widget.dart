import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_sound/android_encoder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:mobile_application/widgets/phone/explore/circular_button.dart';
import 'package:flutter/services.dart' show rootBundle;

class AudioWidget extends StatefulWidget {
  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget>
    with TickerProviderStateMixin {
  static const String paths = "sound.aac";

  FlutterFFmpeg ffmpeg = FlutterFFmpeg();
  bool _isRecording = false;
  String _path;
  String _recorderTxt = '00:00:00';
  double _dbLevel;

  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;

  FlutterSound flutterSound;

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.1);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  @override
  void dispose() {
    if (flutterSound.isRecording) {
      flutterSound.stopRecorder();
    }

    super.dispose();
  }

  ///
  /// Recording
  ///
  void recorderStateCallback(RecordStatus recordStatus) {
    if (recordStatus == null) {
      return;
    }

    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      (recordStatus.currentPosition.toInt() - 100),
      isUtc: true,
    );
    String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

    setState(() => _recorderTxt = txt.substring(0, 8));
  }

  void recorderDbPeakCallback(double dbPeak) {
    print("got update -> $dbPeak");
    _dbLevel = dbPeak;
  }

  void recordingStreamsSubscription() {
    _recorderSubscription = flutterSound.onRecorderStateChanged.listen(
      recorderStateCallback,
    );
    _dbPeakSubscription = flutterSound.onRecorderDbPeakChanged.listen(
      recorderDbPeakCallback,
    );
  }

  void removeRecordingStreams() {
    _recorderSubscription?.cancel();
    _dbPeakSubscription?.cancel();
  }

  void startRecorder() async {
    if (_isRecording) {
      return;
    }

    ///Setting this earlier to avoid double taps.
    _isRecording = true;

    try {
      /// If the player is active, we first proceed in stopping it.
      /// Otherwise, an error is thrown.
      if (flutterSound.audioState != t_AUDIO_STATE.IS_STOPPED) {
        await flutterSound.stopPlayer();
      }

      String path = await flutterSound.startRecorder(
        paths,
        codec: t_CODEC.CODEC_AAC,
        sampleRate: 16000,
        bitRate: 16000,
        numChannels: 2,
        androidAudioSource: AndroidAudioSource.MIC,
        iosQuality: IosQuality.HIGH,
      );

      recordingStreamsSubscription();
      setState(() => _path = path);
    } catch (err) {
      print('startRecorder error: $err');
      _isRecording = false;
    }
  }

  void stopRecorder() async {
    if (!_isRecording) {
      return;
    }

    ///Setting this earlier to avoid double taps.
    _isRecording = false;

    try {
      await flutterSound.stopRecorder();
      removeRecordingStreams();

      int duration = await ffmpeg
          .getMediaInformation(_path)
          .then((info) => info["duration"].toInt());

      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        duration,
        isUtc: true,
      );
      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

      setState(() => _recorderTxt = txt.substring(0, 8));
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _isRecording ? PulseAnimation() : const SizedBox(),
        Expanded(
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => SlideTransition(
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                position:
                    Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
                        .animate(animation),
              ),
              child: _isRecording
                  ? Container(
                      key: ValueKey("IsRecording"),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(_recorderTxt),
                    )
                  : _path != null
                      ? AudioPlayer(
                          audioTime: _recorderTxt,
                          flutterSound: flutterSound,
                          filePath: _path,
                        )
                      : Container(
                          key: ValueKey("NothingHappening"),
                        ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(
            child: child,
            scale: animation,
          ),
          child: _isRecording
              ? Container(
                  key: ValueKey("StopButton"),
                  child: CircularButton(
                    assetPath: "ic_stop.png",
                    alignment: Alignment.center,
                    onPressFunction: stopRecorder,
                    height: 40,
                    width: 40,
                    applyElevation: false,
                  ),
                )
              : Container(
                  key: ValueKey("RecordButton"),
                  child: CircularButton(
                    assetPath: "ic_mic.png",
                    alignment: Alignment.center,
                    onPressFunction: startRecorder,
                    height: 40,
                    width: 40,
                    applyElevation: false,
                  ),
                ),
        ),
      ],
    );
  }
}

class PulseAnimation extends StatefulWidget {
  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(
                sin(_pulseController.value * pi),
              ),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

class AudioPlayer extends StatefulWidget {
  final String audioTime;
  final String filePath;
  final FlutterSound flutterSound;

  AudioPlayer({
    this.audioTime,
    this.filePath,
    this.flutterSound,
  });

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  bool _isPlaying = false;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  String _playerTime;
  StreamSubscription _playerSubscription;

  @override
  void initState() {
    super.initState();
    _playerTime = widget.audioTime;
    print(_playerTime);
  }

  @override
  void dispose() {
    if (widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED) {
      widget.flutterSound.stopPlayer();
    }

    super.dispose();
  }

  ///
  /// Playing
  ///
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  void playerStateCallback(PlayStatus playStatus) {
    print(playStatus);
    // The player is running
    if (playStatus != null) {
      sliderCurrentPosition = playStatus.currentPosition;
      maxDuration = playStatus.duration;

      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        playStatus.currentPosition.toInt(),
        isUtc: true,
      );

      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() => _playerTime = txt.substring(0, 8));
    } else {
      setState(() => _isPlaying = false);
    }
  }

  void playerStreamsSubscription() {
    _playerSubscription = widget.flutterSound.onPlayerStateChanged.listen(
      playerStateCallback,
    );
  }

  void removePlayerStreams() {
    _playerSubscription?.cancel();
  }

  void startPlayer() async {
    try {
      if (await fileExists(widget.filePath)) {
        String path = await widget.flutterSound.startPlayer(widget.filePath);

        if (path == null) {
          print('Error starting player');
          return;
        }
      }

      await widget.flutterSound.setVolume(1.0);
      playerStreamsSubscription();

      if (sliderCurrentPosition != maxDuration) {
        print("Not finished playing!");
        await widget.flutterSound.seekToPlayer(sliderCurrentPosition.toInt());
      }
      setState(() => _isPlaying = true);
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    try {
      String result = await widget.flutterSound.pausePlayer();
      removePlayerStreams();
      print('pausePlayer: $result');
    } catch (err) {
      print('error: $err');
    }

    setState(() => _isPlaying = false);
  }

  void seekToPlayer(int milliSecs) async {
    String result = await widget.flutterSound.seekToPlayer(milliSecs);
    print('seekToPlayer: $result');
  }

  String timeToShow() {
    return widget.flutterSound.audioState != t_AUDIO_STATE.IS_STOPPED ||
            sliderCurrentPosition != maxDuration
        ? _playerTime
        : widget.audioTime;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey("RecordedAudio"),
      direction: DismissDirection.endToStart,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          const Radius.circular(24),
        ),
        child: Container(
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: ThemeProvider.primaryColor.withOpacity(0.25),
            child: Row(
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    child: child,
                    scale: animation,
                  ),
                  child: _isPlaying
                      ? Container(
                          key: ValueKey("PauseButtonPlayer"),
                          child: CircularButton(
                            assetPath: "ic_pause.png",
                            alignment: Alignment.center,
                            onPressFunction: pausePlayer,
                            height: 40,
                            width: 40,
                            applyElevation: false,
                          ),
                        )
                      : Container(
                          key: ValueKey("PlayButtonPlayer"),
                          child: CircularButton(
                            assetPath: "ic_play.png",
                            alignment: Alignment.center,
                            onPressFunction: startPlayer,
                            height: 40,
                            width: 40,
                            applyElevation: false,
                          ),
                        ),
                ),
                Container(
                  child: Text(timeToShow()),
                ),
              ],
            ),
          ),
        ),
      ),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            const Radius.circular(24),
          ),
          color: Colors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text("Delete"),
            Container(
              height: 35,
              width: 35,
              child: ImageWrapper(assetPath: AssetImages.DELETE),
            ),
          ],
        ),
      ),
    );
  }
}
