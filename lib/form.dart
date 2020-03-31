import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:signature_app/api/url.dart';
import 'package:signature_app/file_object.dart';
import 'package:signature_app/results.dart';
import 'package:signature_app/camera.dart';
import 'package:camera/camera.dart';


class SignatureForm extends StatefulWidget {
  final CameraDescription camera;
  final double statusBarHeight;
  File imageFile;
  String type;
  
  SignatureForm({Key key, this.camera, this.statusBarHeight,this.imageFile,this.type}) : super(key: key);

  @override
  SignatureFormState createState() => SignatureFormState();
}

class SignatureFormState extends State<SignatureForm> {
  final _formKey = GlobalKey<FormState>();

  double _values = 0.7;
  static FileObject signature1 = new FileObject(null,null);
  static FileObject signature2 = new FileObject(null,null);

  Future getImage(source,type) async {
    var image = await ImagePicker.pickImage(source: source);
    var rotatedImage = image;
    if(type == 'signature1'){
      setState(() {
        signature1.setFile(rotatedImage,'img');
      });
    } else if(type == 'signature2'){
      setState(() {
        signature2.setFile(rotatedImage,'img');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.imageFile != null){
      if(widget.type == 'signature1'){
        setState(() {
          print(widget.imageFile);
          signature1.setFile(widget.imageFile,'img');
        });
      } else if(widget.type == 'signature2'){
        setState(() {
          signature2.setFile(widget.imageFile,'img');
        });
      }
    }
  }

  selectPhotoOption(type) async{
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Photo Options'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  // getImage(ImageSource.camera,type);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(camera:widget.camera,statusBarHeight:widget.statusBarHeight,type:type),
                    ),
                  );
                },
                child: const Text('Camera'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  getImage(ImageSource.gallery,type);
                },
                child: const Text('Gallery'),
              )
            ],
          );
        }
    );
  }

  _submitImageForOcr() async{
    _showLoadingDialog();
    var _image1 = signature1.getImage();
    var _image2 = signature2.getImage();
    var uri = Uri.parse(API.url);
    var request = new http.MultipartRequest("POST", uri);
    request.fields['threshold'] = _values.toStringAsFixed(1);
    print(request.fields['threshold']);
    request.files.add(await http.MultipartFile.fromPath(
    's1',
    _image1.path));
    request.files.add(await http.MultipartFile.fromPath(
    's2',
    _image2.path));
    
    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
          Navigator.of(context, rootNavigator: true).pop();
          if (response.statusCode == 200)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Results(result: response.body.toString()),
              ),
            );
            print('response.body '+response.body);
          } else {
            var error = 'error : '+response.body.toString();
            print('error');
            print(error);
            _showAlertDialog('Invalid Result');
          }
          return response.body;
      }).catchError((err){
          return 500;
      });
    });
  }

  _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  child: new CircularProgressIndicator(
                    backgroundColor: Color(0xffea5402),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: new Text("Loading..."),
                )
              ],
            ),
          );
        });
  }

  _showErrorDialog(error) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: new Text(error),
                )
              ],
            ),
          );
        });
  }

  _showAlertDialog(error) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(error),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  clearImage(imageFile){
    setState(() {
      imageFile.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(key: _formKey, child: Column(children: getFormWidget(size,_formKey)));
  }

  List<Widget> getFormWidget(size,key) {
    List<Widget> formWidget = new List();
    File _image1 = signature1.getImage();
    File _image2 = signature2.getImage();
    formWidget.add(Container(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
        padding: EdgeInsets.fromLTRB(5,0,0,0),
          child: Text('Signature 1'),
        ),
        Card(
        child:Container(
            height: 170,
            width: 300,
            child: ( _image1 == null)
                ? RawMaterialButton(
                    onPressed: (){
                      selectPhotoOption('signature1');
                    },
                    child: Center(
                    // color: Color(0xffea5402),
                    // shape: new CircleBorder(),
                      child: Icon(
                        Icons.add_a_photo,
                      ),
                    )
                  )
                : Stack(
                    children: <Widget>[
                      Center(child: 
                        Image.file(_image1),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: IconButton(
                          onPressed: (){
                            clearImage(signature1);
                          },
                          icon: Icon(Icons.clear,
                          color: Colors.grey,)
                        )
                      )
                    ]
              )
          )
        )
      ],
    )));

    formWidget.add(Container(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
        padding: EdgeInsets.fromLTRB(5,20,0,0),
          child: Text('Signature 2'),
        ),
        Card(
        child:Container(
            height: 170,
            width: 300,
            child: (_image2 == null)
                ? RawMaterialButton(
                    onPressed: (){
                      selectPhotoOption('signature2');
                    },
                    child: Center(
                    // color: Color(0xffea5402),
                    // shape: new CircleBorder(),
                      child: Icon(
                        Icons.add_a_photo,
                      ),
                    )
                  )
                : Stack(
                    children: <Widget>[
                      Center(child: 
                        Image.file(_image2),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: IconButton(
                          onPressed: (){
                            clearImage(signature2);
                          },
                          icon: Icon(Icons.clear,
                          color: Colors.grey,)
                        )
                      )
                    ]
              )
          )
        )
      ],
    )));

    formWidget.add(
      Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text('Threshold:',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Slider(
                    label: 'Threshold',
                    min: 0.0,
                    max: 1.0,
                    value: _values,
                    onChanged: (value) {
                      setState(() {
                        _values = value;
                      });
                    },
                  )
                ),
                Text(_values.toStringAsFixed(1))
            ],)
        ],)
      )
    );

    formWidget.add(
      new Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
        child: RaisedButton(
          color: Color(0xffea5402),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              if (_image1 != null && _image2 != null) {
                _submitImageForOcr();
              } else {
                _showAlertDialog('Please ensure both images are upload');
              }
            }
          },
          child: Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    return formWidget;
  }
}
