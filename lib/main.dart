import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uterra/button_with_icon.dart';

void main() {
  runApp(MyApp());
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

  @override
  Widget build(BuildContext context) {
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
      onPressed: () {  },
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      borderSide: BorderSide(color: Color(0xFFC54B3D), style: BorderStyle.solid, width: 1),
      label: Text('COMENZAR VIAJE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      icon: Image(image: AssetImage('assets/next.png'), width: 5),
    );
  }


}
