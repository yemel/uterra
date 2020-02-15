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

class _MyHomePageState extends State<MyHomePage> {

  int _screen = 0;


  bool playing = false;
  double currentVol = 1;
  AudioCache player = AudioCache();

  AudioPlayer audio;
  Duration audioDuration;
  Duration audioPosition;

  @override
  void initState() {
    super.initState();
    player.load('meditation.mpeg');
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            // Go Back
            OutlineButton.icon(
              onPressed: () => setState(() {
                _screen = 0;
                stopMeditation();
              }),
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              borderSide: BorderSide(color: Color(0xFFC54B3D), style: BorderStyle.solid, width: 1),
              icon: Image(image: AssetImage('assets/back.png'), width: 5),
              label: Text('SALIR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),

            // Volume Controls
            Container(
              decoration: BoxDecoration(border: Border.all(color: Color(0xFFBCA4A1)), borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.all(15),
              child: Row(children: [
              
              // Volume Down
              SizedBox(height: 5, child: IconButton(
                  padding: new EdgeInsets.all(0),
                  icon: Image(width: 10, image: AssetImage('assets/minus.png')),
                  onPressed: () => volumeDown()
              )),

              Text('VOLUMEN'),

              // Volume UP
              SizedBox(height: 10, child: IconButton(
                  padding: new EdgeInsets.all(0),
                  icon: Image(image: AssetImage('assets/plus.png')),
                  onPressed: () => volumeUp()
              )),
            ]))
            // Text('VOLUMEN', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFFC54B3D), letterSpacing: 1.02)),
          ]),

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

          Positioned(bottom: 10, child: _buildPosition()),
          Positioned(bottom: 10, right: 0, child: _buildDuration()),
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
    // return RaisedGradientButton(child: Text('hola'), gradient: LinearGradient(
    //   colors: <Color>[Color(0xFFC54B3D), Colors.black],
    //   stops: [0.2, 0.2],
    // ));

    return OutlineButtonWithIcon(
      onPressed: () => setState(() {
        _screen = 1;
        startMeditation();
      }),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      borderSide: BorderSide(color: Color(0xFFC54B3D), style: BorderStyle.solid, width: 1),
      label: Text('COMENZAR VIAJE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      icon: Image(image: AssetImage('assets/next.png'), width: 5),
    );
  }

  Widget _buildButton2() {
    return OutlineButton.icon(
      onPressed: () => setState(() => _screen = 0),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      borderSide: BorderSide(color: Color(0xFFC54B3D), style: BorderStyle.solid, width: 1),
      label: Text('VOLVER AL INICIO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      icon: Image(image: AssetImage('assets/back.png'), width: 5),
    );
  }

  Widget _buildDuration() {
    if (audioDuration == null) return Text('');
    return Text('${audioDuration.inMinutes}:${audioDuration.inSeconds % 60}');
  }

  Widget _buildPosition() {
    if (audioPosition == null) return Text('');
    return Text('${audioPosition.inMinutes}:${audioPosition.inSeconds % 60}');
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
        print('Update: ${_screen}');
        if (_screen == 1 && d.inMinutes >= 9 && d.inSeconds % 60 >= 9) {
          _screen = 2;
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

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50.0,
      decoration: BoxDecoration(gradient: gradient),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}