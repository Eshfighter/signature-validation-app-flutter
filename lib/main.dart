import 'package:flutter/material.dart';
import 'package:signature_app/form.dart';
import 'package:camera/camera.dart';

import 'dart:io';

void main() async{
   // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
} 

// A screen that allows users to take a picture using a given camera.
class MyApp extends StatefulWidget {
  final CameraDescription camera;
  final File imageFile;
  final String type;

  const MyApp({
    Key key,
    @required this.camera,
    this.imageFile,
    this.type
  }) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(136, 14, 79, .1),
      100: Color.fromRGBO(136, 14, 79, .2),
      200: Color.fromRGBO(136, 14, 79, .3),
      300: Color.fromRGBO(136, 14, 79, .4),
      400: Color.fromRGBO(136, 14, 79, .5),
      500: Color.fromRGBO(136, 14, 79, .6),
      600: Color.fromRGBO(136, 14, 79, .7),
      700: Color.fromRGBO(136, 14, 79, .8),
      800: Color.fromRGBO(136, 14, 79, .9),
      900: Color.fromRGBO(136, 14, 79, 1),
    };
    return MaterialApp(
      title: 'Signature Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xffea5402, color),
      ),
      home: MyHomePage(title: 'Signature Verification', camera: widget.camera,imageFile:widget.imageFile,type: widget.type),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  final File imageFile;
  final String type;
  
  MyHomePage({Key key, this.title, this.camera,this.imageFile,this.type}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[SignatureForm(camera: widget.camera,statusBarHeight:statusBarHeight,imageFile:widget.imageFile,type:widget.type)],
              ),
            ),
          ],
        ));
  }
}
