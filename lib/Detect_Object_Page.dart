import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:newobjectdetectionyolov5/LoaderState.dart';
import 'package:newobjectdetectionyolov5/add_recipe.dart';
import 'package:newobjectdetectionyolov5/recipe_list.dart';

class detect_object_page extends StatefulWidget {
  const detect_object_page({Key? key}) : super(key: key);

  @override
  State<detect_object_page> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<detect_object_page> {
  late ModelObjectDetection _objectModel;
  List<ResultObjectDetection?> objDetect = [];
  File? _image;
  ImagePicker _picker = ImagePicker();
  bool firststate = false;
  bool message = true;
  List<String> classNames = [];

  @override
  void initState() {
    super.initState();
    loadModel();
    runObjectDetection();
  }

  Future<void> loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov5s.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
        pathObjectDetectionModel,
        80,
        640,
        640,
        labelPath: "assets/labels/labels.txt",
      );
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  void handleTimeout() {
    setState(() {
      firststate = true;
    });
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);

  Future<void> runObjectDetection() async {
    setState(() {
      firststate = false;
      message = false;
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    objDetect = await _objectModel.getImagePrediction(
      await File(image!.path).readAsBytes(),
      minimumScore: 0.1,
      IOUThershold: 0.3,
    );

    // Extract class names
    classNames = [];
    for (var detection in objDetect) {
      classNames.add(detection?.className ?? '');
    }

    scheduleTimeout(5 * 1000);
    setState(() {
      _image = File(image.path);
    });
  }

  resultData() {
    var result = classNames;
    
  }

  Future<void> runObjectDetectionAgain() async {
    setState(() {
      message = false;
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    objDetect = await _objectModel.getImagePrediction(
      await File(image!.path).readAsBytes(),
      minimumScore: 0.1,
      IOUThershold: 0.3,
    );

    // Extract class names
    classNames = [];
    for (var detection in objDetect) {
      classNames.add(detection?.className ?? '');
    }

    scheduleTimeout(5 * 1000);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMART PALATE"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !firststate
                ? !message
                    ? LoaderState()
                    : Text("Select the Camera to Begin Detections")
                : Expanded(
                    child: Container(
                      child:
                          _objectModel.renderBoxesOnImage(_image!, objDetect),
                    ),
                  ),
            SizedBox(
              height: 100,
            ),
            ElevatedButton(
              onPressed: () {
                runObjectDetectionAgain();
              },
              child: Text('Retake Photo'),
            ),
            SizedBox(
              height: 80,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecipeList(resultData: classNames)),
                );
              },
              child: const Text('Print Recipe'),
            ),
             SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
