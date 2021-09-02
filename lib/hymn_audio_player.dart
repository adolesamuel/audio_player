import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

//Errors Exists BUt the main build is an audio player container
class HymnAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool isVisible;
  final Color themeColor;
  const HymnAudioPlayer({
    Key key,
    this.audioUrl,
    this.isVisible,
    this.themeColor,
  }) : super(key: key);

  @override
  _HymnAudioPlayerState createState() => _HymnAudioPlayerState();
}

class _HymnAudioPlayerState extends State<HymnAudioPlayer> {
  AudioPlayer hymnsPlayer; //AudioPlayer controller equivalent

  PlayerState playerState = PlayerState.STOPPED; //initial player state

  bool get isPlaying => playerState == PlayerState.PLAYING;

  Duration totalDuration =
      Duration.zero; //total length of audio, initialised at Duration.zero

  Duration currentPosition = Duration.zero; //current position of audio

  @override
  void initState() {
    super.initState();
    hymnsPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    AudioPlayer.logEnabled = false; //switch of logs

    //Error Listener
    hymnsPlayer.onPlayerError.listen((msg) {
      print('AudioPlayer error: $msg');
      setState(() {
        playerState = PlayerState.STOPPED;
      });
    });

    //Duration Listner
    hymnsPlayer.onDurationChanged.listen((Duration dur) {
      setState(() {
        totalDuration = dur;
      });
    });

    //CurrentPosition listener
    hymnsPlayer.onAudioPositionChanged.listen((Duration dur) {
      setState(() => currentPosition = dur);
    });

    //  playPause();
  }

  @override
  void dispose() {
    hymnsPlayer.dispose();
    super.dispose();
  }

  //Play and Pause method for restarting a playback
  playPause() async {
    if (playerState == PlayerState.PLAYING) {
      final playerResult = await hymnsPlayer.pause();
      if (playerResult == 1) {
        setState(() {
          playerState = PlayerState.PAUSED;
        });
      }
    } else if (playerState == PlayerState.PAUSED) {
      final playerResult = await hymnsPlayer.resume();
      if (playerResult == 1) {
        setState(() {
          playerState = PlayerState.PLAYING;
        });
      }
    } else {
      final playerResult = await hymnsPlayer.play(widget.audioUrl);
      if (playerResult == 1) {
        setState(() {
          playerState = PlayerState.PLAYING;
        });
      }
    }
  }

//Set position on seek
  void seekPosition(double value) {
    var positionInSeconds = value * totalDuration.inSeconds;
    Duration position = Duration(seconds: positionInSeconds.toInt());
    hymnsPlayer.seek(position);
    if (playerState != PlayerState.PLAYING) {
      hymnsPlayer.resume();
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes);
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  double getDoubleFromDurationDivision(
      Duration smallDuration, Duration bigDuration) {
    double small = smallDuration == Duration.zero
        ? 0.001
        : smallDuration.inSeconds.toDouble();
    double large =
        bigDuration == Duration.zero ? 1.0 : bigDuration.inSeconds.toDouble();

    double value = small / large;
    print("double $small");
    return value;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Visibility(
      visible: widget.isVisible,
      child: Card(
        elevation: 16.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: widget.themeColor.withOpacity(0.8) ?? Colors.white,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          height: 50.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_printDuration(currentPosition)),
              InkWell(
                  onTap: () async {
                    await playPause();
                  },
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
              Container(
                width: size.width * 0.6,
                child: Slider(
                    activeColor: Colors.grey,
                    value: getDoubleFromDurationDivision(
                        currentPosition, totalDuration),
                    onChanged: (double value) {
                      seekPosition(value);
                    }),
              ),
              Text(_printDuration(totalDuration)),
              InkWell(
                  onTap: () {
                    print('stop');
                  },
                  child: Icon(Icons.stop)),
            ],
          ),
        ),
      ),
    );
  }
}
