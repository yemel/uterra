import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uterra/button_with_icon.dart';
import 'package:audioplayers/audio_cache.dart';

void main() async {
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(fontFamily: 'Roboto', textTheme: Typography.whiteMountainView),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  int _screen = 0;

  bool playing = false;
  double currentVol = 1;
  AudioCache player = AudioCache();

  AudioPlayer audio;
  Duration audioDuration;
  Duration audioPosition;

  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    player.load('meditation.mpeg');

    controller = AnimationController(duration: Duration(seconds: 90), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
    animation.addListener(() => setState((){
      if(animation.value > 0.99 && _screen == 2) {
        _screen = 0;
        controller.reset();
      }
    }));
  }

  volumeUp() async {
    currentVol = min(1.0, currentVol + 0.15);
    if(audio != null) audio.setVolume(currentVol);
  }

  volumeDown() async {
    currentVol = max(0, currentVol - 0.15);
    if(audio != null) audio.setVolume(currentVol);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
    AnimatedOpacity(opacity: _screen == 2 ? 1 : 0, duration: Duration(seconds: 1), child: IgnorePointer(child: _buildFinish(), ignoring: _screen != 2)),
    AnimatedOpacity(opacity: _screen == 1 ? 1 : 0, duration: Duration(seconds: 1), child: IgnorePointer(child: _buildPlayer(), ignoring: _screen != 1)),
    AnimatedOpacity(opacity: _screen == 0 ? 1 : 0, duration: Duration(seconds: 1), child: IgnorePointer(child: _buildHome(), ignoring: _screen != 0)),
    ]);
  }

  Widget _buildFinish() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top:40, left: 20, bottom: 30, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('GRACIAS POR VIAJAR CON UTERRA', style: TextStyle(fontSize: 10, color: Color(0xFF735C59), letterSpacing: 1.04)),
            Text('Ya llegamos. Hola de nuevo.', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFFC54B3D), letterSpacing: 1.02)),
          ])),

          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
            Expanded(child: _buildItem('assets/eye.png', 'Ayudate', 'Tomate unos minutos\nantes de salir al mundo;\nacabas de renacer.')),
            Expanded(child: _buildItem('assets/share.png', 'Compartí', 'Invita a tus amiges a que\nexperimenten Uterra por\nsí mismes.')),
            Expanded(child: _buildItem('assets/thanks.png', 'Ayudanos', 'Al salir, por favor dejá\ntodo igual o mejor que\ncomo estaba antes.')),
          ]),

          _buildButton2(),
        ]),
      )
    );
  }

  Widget _buildPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top:40, left: 20, right: 20),
        child: Stack(
          children: [
          Opacity(opacity: 0.5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // Go Back
            OutlineButton.icon(
              onPressed: () => setState(() {
                _screen = 0;
                stopMeditation();
              }),
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              borderSide: BorderSide(color: Color(0xFFC54B3D), style: BorderStyle.solid, width: 1),
              highlightedBorderColor: Color(0xFF6D1716),
              icon: Image(image: AssetImage('assets/back.png'), width: 5),
              label: Text('SALIR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),

            // Volume Controls
            Container(
              decoration: BoxDecoration(border: Border.all(color: Color(0xFFBCA4A1)), borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.only(top: 4, right: 4, bottom: 4),
              child: Row(children: [
              
              // Volume Down
              GestureDetector(
                onTap: () => volumeDown(),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFC54B3D), width: 2),  
                  ),
                  child: Image(image: AssetImage('assets/minus.png'), width: 12)
              )),

              SizedBox(width: 18),
              Text('VOLUMEN'),
              SizedBox(width: 18),

              // Volume UP
              GestureDetector(
                onTap: () => volumeUp(),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFC54B3D), width: 2),  
                  ),
                  child: Image(image: AssetImage('assets/plus.png'), width: 10)
              )),

            ]))
          ])),

          // Center Cirlce
          Center(child: GestureDetector(
            onTap: () => setState(() => playing ? pauseMeditation() : resumeMeditation()),
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0xFFC54B3D), blurRadius: 0),
                  BoxShadow(color: Colors.black, blurRadius: 10),
                ],
                border: Border.all(color: Color(0xFFC54B3D), width: 2),
          )))),
          
          // Pause Button
          AnimatedOpacity(opacity: playing ? 1 : 0, duration: Duration(milliseconds: 500), child:
              IgnorePointer(child: Center(child: Image(image: AssetImage('assets/pause.png'), width: 30)))
          ),

          // Play Button
          AnimatedOpacity(opacity: playing ? 0 : 1, duration: Duration(milliseconds: 500), child:
            IgnorePointer(child: Center(child: Container(margin: EdgeInsets.only(left: 12), child: Image(image: AssetImage('assets/play.png'), width: 40)))),
          ),

          AnimatedOpacity(opacity: playing ? 0 : 1, duration: Duration(milliseconds: 500), child:
            IgnorePointer(child: Center(child: 
            Container(
              margin: EdgeInsets.only(top: 220),
              child: audioPosition == null ? null : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sólo faltan ', style: TextStyle(color: Color(0xFF5E5250), fontSize: 16, letterSpacing: 1.04)),
                  _buildRemaining(),
              ]),
          )))),

          Positioned(bottom: 10, child: 
            AnimatedOpacity(opacity: playing ? 0.7 : 0, duration: Duration(milliseconds: 500), child: _buildPosition())
          ),
          Positioned(bottom: 10, right: 0, child:
            AnimatedOpacity(opacity: playing ? 0.7 : 0, duration: Duration(milliseconds: 500), child: _buildDuration())
          ),
          Positioned(bottom: 1, child: AnimatedContainer(color: Color(0xFFC54B3D), height: 2, width: _getProgress(), duration: Duration(seconds: 1))),

          Positioned(bottom: 50, right: 10, child: GestureDetector(
            onTap: () => _handleSkip(),
            child: Container(width: 220, height: 220, color: Colors.black))
          ),
        ]),
      )
    );
  }

  Widget _buildHome() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top:40, left: 20, bottom: 30, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('BIENVENIDE A UTERRA', style: TextStyle(fontSize: 10, color: Color(0xFF735C59), letterSpacing: 1.04)),
            Text('Viajemos juntes.', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFFC54B3D), letterSpacing: 1.02)),
          ])),

          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
            Expanded(child: _buildItem('assets/pods.png', 'Ponete los auris', 'Están apoyados abajo\nde la pantalla.')),
            Expanded(child: _buildItem('assets/rest.png', 'Ponete cómode', 'Te recomendamos la\nposición fetal.')),
            Expanded(child: _buildItem('assets/clock.png', 'Quedate', 'La experiencia dura\n10 minutos.')),
          ]),

          _buildButton(),
        ]),
      )
    );
  }

  Widget _buildItem(String iconPath, String title, String description) {
    return Row(children: [Flexible(child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Image(width: 25, image: AssetImage(iconPath)),
        SizedBox(height: 15),
        Text(title, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w300, letterSpacing: 1.02)),
        SizedBox(height: 2),
        Text(description, style: TextStyle(fontSize: 14, color: Color(0xFFBCA4A1), height: 1.5, letterSpacing: 1.04)),
      ]))
    ]);
  }


  Widget _buildButton() {
    return OutlineButtonWithIcon(
      onPressed: () => setState(() {
        _screen = 1;
        startMeditation();
      }),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      borderSide: BorderSide(color: Color(0xFFC54B3D), style: BorderStyle.solid, width: 1),
      highlightedBorderColor: Color(0xFF6D1716),
      label: Text('COMENZAR VIAJE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.04)),
      icon: Image(image: AssetImage('assets/next.png'), width: 6),
    );
  }

  Widget _buildButton2() {
    return GestureDetector(
      onTap: () => setState(() {
        _screen = 0;
        controller.reset();
      }),
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFFC54B3D), width: 1),
        gradient: LinearGradient(
          colors: <Color>[Color(0x55CE0200), Color(0x55C54B3D), Colors.black],
          stops: [0, animation.value, animation.value],
        )
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(image: AssetImage('assets/back.png'), width: 6),
          SizedBox(width: 18),
          Text('VOLVER AL INICIO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.04)),
    ])));
  }

  Widget _buildDuration() {
    if (audioDuration == null) return Text('');
    return Text('${audioDuration.inMinutes}:${audioDuration.inSeconds % 60}');
  }

  Widget _buildPosition() {
    if (audioPosition == null) return Text('');
    return Text('${audioPosition.inMinutes}:${audioPosition.inSeconds % 60}');
  }

  Widget _buildRemaining() {
    if (audioPosition == null) return Text('');
    Duration rest = audioDuration - audioPosition;
    return Text('${rest.inMinutes}:${rest.inSeconds % 60}', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.04, fontWeight: FontWeight.w700));
  }

  double _getProgress() {
    if(audioPosition == null || audioDuration == null) return 0;
    var progress = audioPosition.inSeconds / audioDuration.inSeconds;
    return MediaQuery.of(context).size.width * progress;
  }

  void startMeditation() async {
    playing = true;
    audio = await player.play('meditation.mpeg', stayAwake: true);

    audio.onDurationChanged.listen((Duration d) {
      if(audioDuration != null) return;
      setState(() => audioDuration = d);
    });

    audio.onAudioPositionChanged.listen((Duration d) {
      if (audioPosition != null && audioPosition.inSeconds == d.inSeconds) return;
      setState(() {
        audioPosition = d;
        if (_screen == 1 && d.inMinutes >= 9 && d.inSeconds % 60 >= 9) {
          _screen = 2;
          controller.reset();
          controller.forward();
        }
      });
    });
  }

  void stopMeditation() {
    playing = false;
    audio.stop();
  }

  void pauseMeditation() {
    playing = false;
    audio.pause();
  }

  void resumeMeditation() {
    playing = true;
    audio.resume();
  }

  int _tapCount = 0;
  int _lastTap = 0;
  void _handleSkip() {
    int now = DateTime.now().millisecondsSinceEpoch;
    _tapCount = now - _lastTap < 1500 ? _tapCount + 1 : 1;
    _lastTap = now;
    if(_tapCount == 5) audio.seek(Duration(minutes: 9));
  }
}
