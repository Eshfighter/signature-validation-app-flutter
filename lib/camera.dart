import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:signature_app/main.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final double statusBarHeight;
  final String type;

  const TakePictureScreen({
    Key key,
    this.statusBarHeight,
    @required this.camera,
    this.type
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  GlobalKey _cropArea = GlobalKey();
  GlobalKey _cameraArea = GlobalKey();
  File _imageFile;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AppBar appBar = AppBar(
      title: Text('Capture Signature Image'),
    );
    return Scaffold(
      appBar: appBar,
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Positioned.fill(
                  child: new AspectRatio(
                      key: _cameraArea,
                      aspectRatio: 1.5,
                      child: (_imageFile == null) ?new CameraPreview(_controller) : Container(color: Colors.black)),
                ),
                Column(
                  children: [
                    Container(
                      height: 100,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    Container(
                      height: 224,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 15,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          Expanded(
                            child: (_imageFile == null) ? Container(
                              key: _cropArea,
                              color: Colors.transparent,
                            ) :
                            Image.file(File(_imageFile.path))
                          ),
                          Container(
                            width: 15,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Container(
                      color: Colors.black,
                      height: 175,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (_imageFile != null) ?
                          Container(
                            margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle,
                            ),
                            child: RawMaterialButton(
                              onPressed: (){
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                              child: Icon(Icons.clear,color: Colors.white,),
                            ),
                          ): Container(),
                          (_imageFile == null) ?
                            RawMaterialButton(
                              onPressed: () async {
                                // Take the Picture in a try / catch block. If anything goes wrong,
                                // catch the error.
                                  // Ensure that the camera is initialized.
                                await _initializeControllerFuture;

                                // Construct the path where the image should be saved using the
                                // pattern package.
                                final path = join(
                                  // Store the picture in the temp directory.
                                  // Find the temp directory using the `path_provider` plugin.
                                  (await getTemporaryDirectory()).path,
                                  '${DateTime.now()}.png',
                                );

                                // Attempt to take a picture and log where it's been saved.
                                await _controller.takePicture(path);

                                ImageProperties properties = await FlutterNativeImage.getImageProperties(path);
                                print(properties.height);
                                print(properties.width);

                                double topBarheight = appBar.preferredSize.height + widget.statusBarHeight;
                                print(topBarheight);
                              
                                // If the picture was taken, display it on a new screen.
                                final RenderBox renderBoxRed = _cropArea.currentContext.findRenderObject();
                                final sizeRed = renderBoxRed.size;
                                final positionRed = renderBoxRed.localToGlobal(Offset.zero);

                                final RenderBox cameraBox = _cameraArea.currentContext.findRenderObject();
                                final sizecameraBox = cameraBox.size;

                                File compressedFile = await FlutterNativeImage.compressImage(path, quality: 100, 
                                targetWidth: sizecameraBox.height.round(), targetHeight: sizecameraBox.width.round());
                                // File compressedFile = await FlutterNativeImage.compressImage(path, quality: 100, 
                                //   targetWidth: 720, targetHeight: 1120);
                                

                                var originX = (positionRed.dy - topBarheight); 
                                var originY = positionRed.dx;
                                File croppedFile = await FlutterNativeImage.cropImage(
                                    compressedFile.path, originX.round(), originY.round(), sizeRed.height.round(), sizeRed.width.round());
                                ImageProperties properties_1 = await FlutterNativeImage.getImageProperties(croppedFile.path);
                                print(properties_1.height);
                                print(properties_1.width);

                                setState(() {
                                  _imageFile = croppedFile;
                                });
                              },
                              child :Container(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                ),
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35),
                                  ),
                                  border: Border.all(
                                    width: 10,
                                    color: Colors.white.withOpacity(.5),
                                  ),
                                ),
                              ),
                            ) : Container(),
                          (_imageFile != null) ?
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 50, 0),
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle,
                            ),
                            child: RawMaterialButton(
                              onPressed: () async{
                                var result = await ImageGallerySaver.saveFile(_imageFile.path);
                                print(result);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyApp(camera: widget.camera,imageFile: _imageFile,type:widget.type),
                                  ),
                                );
                              },
                              child: Icon(Icons.done,color: Colors.white,),
                              // backgroundColor: Colors.transparent,
                            ),
                          ): Container(),
                        ],
                      ),
                    )]
                )
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}