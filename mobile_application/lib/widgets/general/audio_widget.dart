import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_sound/android_encoder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../providers/theming/theme_provider.dart';
import '../../widgets/general/image_wrapper.dart';
import '../../widgets/phone/explore/circular_button.dart';

mixin TimeConverter {
  String timeToString(int duration) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      duration,
      isUtc: true,
    );

    return DateFormat('mm:ss:SS', 'en_GB').format(date).substring(0, 8);
  }
}


class AudioWidget extends StatefulWidget {
  final String audioFilePath;
  final ChangeNotifier notifier;
  final Function setPathInParent;

  AudioWidget({
    @required this.audioFilePath,
    @required this.notifier,
    this.setPathInParent,
  });

  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget>
    with TickerProviderStateMixin, TimeConverter {
  String fileName;

  FlutterFFmpeg ffmpeg = FlutterFFmpeg();
  bool _canRecord = true;
  bool _isRecording = false;
  String _path;
  int _recorderDuration = 0;

  String get _recorderTxt => timeToString(_recorderDuration);
  List<double> _dbLevels = List();

  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;

  FlutterSound flutterSound;

  @override
  void initState() {
    super.initState();

    if (widget.notifier != null) {
      widget.notifier.addListener(() async {
        if (_isRecording) {
          _canRecord = false;
          stopRecorder();
        }
      });
    }

    fileName = widget.audioFilePath;
    flutterSound = FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.1);
    flutterSound.setDbLevelEnabled(true);
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

    setState(
      () => _recorderDuration = recordStatus.currentPosition.toInt() - 100,
    );
  }

  void recorderDbPeakCallback(double dbPeak) {
    if (dbPeak != null) {
      _dbLevels.add(dbPeak);
    }
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
    _dbLevels = List();

    try {
      /// If the player is active, we first proceed in stopping it.
      /// Otherwise, an error is thrown.
      if (flutterSound.audioState != t_AUDIO_STATE.IS_STOPPED) {
        await flutterSound.stopPlayer();
      }

      String path = await flutterSound.startRecorder(
        fileName,
        codec: t_CODEC.CODEC_AAC,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 2,
        androidAudioSource: AndroidAudioSource.MIC,
        iosQuality: IosQuality.HIGH,
      );

      recordingStreamsSubscription();

      setState(() => _path = path);
      widget.setPathInParent(path);
    } catch (err) {
      print('startRecorder error: $err');
      _isRecording = false;
    }
  }

  Future<void> stopRecorder() async {
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

      final double cap = 40;
      List<double> results = List();
      final int averageLength = (_dbLevels.length / cap).ceil();

      for (int i = 0; i < _dbLevels.length; i += averageLength) {
        if (averageLength - i == 1) {
          results.add(_dbLevels
                  .getRange(
                    i,
                    (i + averageLength) <= _dbLevels.length
                        ? (i + averageLength)
                        : averageLength,
                  )
                  .reduce((double x1, double x2) => x1 + x2) /
              averageLength);
        } else {
          results.add(_dbLevels[i]);
        }
      }

      this._dbLevels = results;

      setState(() => _recorderDuration = duration);
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
            height: 60,
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
                          audioDuration: _recorderDuration,
                          flutterSound: flutterSound,
                          filePath: _path,
                          dbPeakSamples: _dbLevels,
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
                    assetPath:
                        _canRecord ? "ic_mic.png" : "ic_mic_disabled.png",
                    alignment: Alignment.center,
                    onPressFunction: _canRecord ? startRecorder : () {},
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
      height: 20,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(
                math.sin(_pulseController.value * math.pi),
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
  final int audioDuration;
  final String filePath;
  final FlutterSound flutterSound;
  final List<double> dbPeakSamples;

  AudioPlayer({
    this.audioDuration,
    this.filePath,
    this.flutterSound,
    this.dbPeakSamples,
  });

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> with TimeConverter {
  bool _isPlaying = false;
  double sliderCurrentPosition = 0.0;
  int maxDuration;
  StreamSubscription _playerSubscription;

  @override
  void initState() {
    super.initState();
    maxDuration = widget.audioDuration;
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
    // The player is running
    if (playStatus != null) {
      sliderCurrentPosition = playStatus.currentPosition;
      maxDuration = playStatus.duration.toInt();

      setState(() {});
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

  Future<void> startPlayer(bool resetState) async {
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
        await widget.flutterSound.seekToPlayer(sliderCurrentPosition.toInt());
      }

      if (resetState) {
        setState(() => _isPlaying = true);
      }
    } catch (err) {
      print('error: $err');
    }
  }

  Future<void> pausePlayer(bool resetState) async {
    try {
      await widget.flutterSound.pausePlayer();
      removePlayerStreams();
    } catch (err) {
      print('error: $err');
    }

    if (resetState) {
      setState(() => _isPlaying = false);
    }
  }

  void seekToPlayer(int milliSecs) async {
    await widget.flutterSound.seekToPlayer(milliSecs);
  }

  String timeToShow() {
    return widget.flutterSound.audioState != t_AUDIO_STATE.IS_STOPPED ||
            (sliderCurrentPosition != maxDuration && sliderCurrentPosition != 0)
        ? timeToString(sliderCurrentPosition.toInt()) +
            "/" +
            timeToString(widget.audioDuration)
        : timeToString(widget.audioDuration);
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSwitcher(
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
                              onPressFunction: () => pausePlayer(true),
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
                              onPressFunction: () => startPlayer(true),
                              height: 40,
                              width: 40,
                              applyElevation: false,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 30,
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: ThemeProvider.primaryColor,
                            inactiveTrackColor: Colors.grey.withOpacity(0.4),
                            trackShape:
                                AudioTrackBarChart(widget.dbPeakSamples),
                            trackHeight: 30,
                            thumbColor: Colors.transparent,
                          ),
                          child: Slider(
                            value: sliderCurrentPosition,
                            max: maxDuration.toDouble(),
                            onChangeStart: (newValue) async {
                              if (_isPlaying) {
                                await pausePlayer(false);
                              }
                            },
                            onChanged: (newValue) {
                              setState(() {
                                sliderCurrentPosition = newValue;
                              });
                            },
                            onChangeEnd: (newValue) async {
                              if (_isPlaying) {
                                await widget.flutterSound.seekToPlayer(
                                    sliderCurrentPosition.toInt());
                                await startPlayer(false);
                              }
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(timeToShow()),
                      ),
                    ],
                  ),
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

///
/// Support classes for forming the slidable audio representation
///

class AudioTrackBarChart extends SliderTrackShape with CustomTrackShape {
  final List<double> dbPeakSamples;

  AudioTrackBarChart(this.dbPeakSamples);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider track height is less than or equal to 0, then it makes no
    // difference whether the track is painted or not, therefore the painting
    // can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final ColorTween inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    double currentBarPosition = trackRect.left;
    final double step = trackRect.width / dbPeakSamples.length;

    for (double dbPeak in dbPeakSamples) {
      final Rect bar = Rect.fromLTWH(
        currentBarPosition + (step * 0.1),
        trackRect.top + trackRect.height * ((120 - dbPeak) / 120) - 2,
        step * 0.8,
        trackRect.height * (dbPeak / 120),
      );

      if (currentBarPosition + (step * 0.9) < thumbCenter.dx) {
        context.canvas.drawRect(
          bar,
          leftTrackPaint,
        );
      } else {
        context.canvas.drawRect(
          bar,
          rightTrackPaint,
        );
      }

      currentBarPosition += step;
    }

    ///Active rectangle
    final Rect underlineBarLeft = Rect.fromLTWH(
      trackRect.left,
      trackRect.bottom - 2,
      thumbCenter.dx - trackRect.left,
      2,
    );

    if (!underlineBarLeft.isEmpty) {
      context.canvas.drawRect(
        underlineBarLeft,
        leftTrackPaint,
      );
    }

    ///Non active rectangle
    final Rect underlineBarRight = Rect.fromLTWH(
      thumbCenter.dx,
      trackRect.bottom - 2,
      trackRect.width - (thumbCenter.dx - trackRect.left),
      2,
    );

    if (!underlineBarRight.isEmpty) {
      context.canvas.drawRect(
        underlineBarRight,
        rightTrackPaint,
      );
    }
  }
}

mixin CustomTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
