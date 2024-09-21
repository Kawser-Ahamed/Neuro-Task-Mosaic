import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:neuro_task_mosaic/data/constant/passage.dart';
import 'package:neuro_task_mosaic/resource/reusable/start_message.dart';
import 'package:neuro_task_mosaic/resource/screen/responsive.dart';
import 'package:neuro_task_mosaic/resource/text/my_text.dart';
import 'package:neuro_task_mosaic/view/home/pages/homepage.dart';
import 'package:neuro_task_mosaic/view_models/grand_father_passage/grand_father_passage_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class GrandFatherRecording extends StatefulWidget {
  const GrandFatherRecording({super.key});

  @override
  State<GrandFatherRecording> createState() => _GrandFatherRecordingState();
}

class _GrandFatherRecordingState extends State<GrandFatherRecording> {

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    //_noiseMeter = NoiseMeter(onError);
    _initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startMessage();
    });
  }

  //Noise Level
  bool _isRecording = false;


  void onError(Object error) {
    // ignore: avoid_print
    print(error);
    _isRecording = false;
  }

  //Timer
  bool recordState = false;
  bool recorded = false;
  int second = 0;
  Timer? timer;

  Future<void> startTimer() async{
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      second++;
      setState(() {

      });
    });
  }

  void stop(){
    timer!.cancel();
  }

  //Audio record
  FlutterSoundRecorder? _recorder;
  String? _filePath;
  bool _isPlaying = false;

  Future<void> _initialize() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    final externalDir = await getExternalStorageDirectory();
    _filePath = '${externalDir!.path}/recording.aac';

    await _recorder!.startRecorder(toFile: _filePath);
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    // ignore: avoid_print
    print('Recording saved to: $_filePath');
    setState(() {});
  }

//Audio Player
  AudioPlayer audioPlayer = AudioPlayer();
  Future<void> _playRecordedAudio() async {
    if (_filePath != null && _filePath!.isNotEmpty) {
      await audioPlayer.setFilePath(_filePath!);
      await audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } else {
      // ignore: avoid_print
      print('File path is null or empty.');
    }
  }

  void _stopPlaying() async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    }
  }
  void _releaseAudioPlayer() {
    audioPlayer.dispose();
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    _recorder!.closeRecorder();
    _releaseAudioPlayer();
    startTimer();
    super.dispose();
  }

  startMessage(){
    return showGeneralDialog(
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.55,
                color: Colors.white,
                child: Card(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text("Grandfather Passage",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (width/Responsive.designWidth) * 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Text("Instruction",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: (width/Responsive.designWidth) * 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.02,vertical: height * 0.02),
                        child: Text("read the passage shown aloud.Tap continue to begin and submit when you are done.",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: (width/Responsive.designWidth) * 30,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextButton(
                        onPressed: (){
                          startTimer();
                          Navigator.pop(context);
                        },
                        child: Text("Continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (width/Responsive.designWidth) * 40,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(166, 207, 207, 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ],
        );
      },
    );
  }

  int count = 0;
  double height = 0.0,width = 0.0;

  @override
  Widget build(BuildContext context) {
    height = Responsive.screenHeight(context);
    width = Responsive.screenWidth(context);
    return Container(
        height: height * 1,
        width: width * 1,
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height * 0.1,
                width: width * 1,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: (){
                          Get.to(const HomePage());
                        },
                        child: Text("Back",
                          style: TextStyle(
                            fontSize: (width / Responsive.designWidth) * 30,
                            color: const Color.fromARGB(166, 207, 207, 11),
                          ),
                        )
                    ),
                    const StartMessage(
                        gameName: 'Grandfather Passage',
                        description: "Read the passage shown aloud.Tap continue to start and submit when you are done."
                    ),
                    TextButton(
                        onPressed: (){
                          _stopPlaying();
                          if(_filePath != null && _filePath!.isNotEmpty){
                            GrandFatherPassageServices.sendAudioToDatabase(_filePath!);
                          }
                        },
                        child: Text("Submit",
                          style: TextStyle(
                            fontSize: (width/Responsive.designWidth) * 30,
                            color: const Color.fromARGB(166, 207, 207, 11),
                          ),
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.05),
              const MyText(text: "Grandfather Passage", size: 20, bold: true, color: Colors.white,height: 0.05,width: 1),
              SizedBox(height: height * 0.02),
              (recordState) ? Container(
                height: height * 0.9,
                width: width * 1,
                color: Colors.transparent,
                child: Column(
                  children: [
                    SizedBox(height: height * 0.1),
                    Container(
                        height:height * 0.4,
                        width: width * 1,
                        color: Colors.transparent,
                        margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                        child: Text(Passage.myText,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (width/Responsive.designWidth) * 30,
                          ),
                        )
                    ),
                    SizedBox(height: height * 0.06),
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          _stopRecording();
                          recordState = false;
                          recorded = true;
                          second = 0;
                          //stop();
                          //stopNoise();
                        });
                        setState(() {

                        });
                      },
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.pink),
                      ),
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: height * 0.015,horizontal: width * 0.05),
                          child: const MyText(text: "Stop recording", size: 20, bold: true, color: Colors.white,height: 0.05,width: 0.4,)
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                height: height * 0.8,
                width: width * 1,
                color: Colors.transparent,
                child: Column(
                  children: [
                    SizedBox(height: height * 0.2),
                    (recorded && (_filePath != null && _filePath!.isNotEmpty))? Container(
                      height: height * 0.07,
                      width: width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular((width/Responsive.designWidth) * 50)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: width * 0.03),
                          GestureDetector(
                            onTap: (){
                              _isPlaying ? _stopPlaying() : _playRecordedAudio();
                              setState(() {

                              });
                            },
                            child: Icon(
                              (_isPlaying)? Icons.stop : Icons.play_arrow,
                              size: (width/Responsive.designWidth) * 40,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          MyText(text: (_isPlaying ? "Playing...." : "Play audio"), size: 30,bold: false, color: Colors.black,height: 0.04,width: 0.3,),
                        ],
                      ),
                    ) : Container(
                      height: height * 0.1,
                      width: width * 0.7,
                      color: Colors.transparent,
                    ),
                    SizedBox(height: height * 0.03),
                    const MyText(text: "Record Audio", size: 30,bold: true, color: Colors.white,height: 0.05,width: 1),
                    SizedBox(height: height * 0.07),
                    GestureDetector(
                      onTap: (){
                        recordState = true;
                        startTimer();
                        _startRecording();
                        recorded = false;
                        setState(() {});
                      },
                      child: Container(
                        height: height * 0.2,
                        width: width * 0.2,
                        decoration: const BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: (width/Responsive.designWidth) * 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}