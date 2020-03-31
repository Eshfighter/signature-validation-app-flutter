import 'package:flutter/material.dart';
import 'dart:convert';

class Results extends StatefulWidget {
  String result;
  Results({Key key, this.result}) : super(key: key);
  @override
  ResultsState createState() => ResultsState();
}

class ResultsState extends State<Results> {
  Map results;

  @override
  void initState() {
    super.initState();
    results = json.decode(widget.result);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Comparison Results'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            textResultBar(results['similarity'],size),
            signatureImagesDisplay(results['s1_processed'],results['s2_processed'])
          ],
        )
      ),
    );
  }

  Widget textResultBar(similarity,size){
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(10,20,10,20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: (results['verification']) ? Colors.green : Colors.red,
          borderRadius: new BorderRadius.circular(10.0)
        ),
        child: (results['verification']) ? 
              Text('The two image-based signatures matched $similarity'):
              Text('The two image-based signatures do not match $similarity')
      )
    );
  }

  Widget signatureImagesDisplay(s1,s2){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child:Text('Processed Images')
          ),
          imageDisplay(s1),
          imageDisplay(s2),
        ]
      ),
    );
  }

  Widget imageDisplay(base64String){
    return Container(
      margin: EdgeInsets.all(10),
      child: Image.memory(base64Decode(base64String)),
    );
  }

}
