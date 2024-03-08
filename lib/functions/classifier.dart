import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:parasite_detector_still/functions/nms.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import '../models/recognitions.dart';

final classifire = StateProvider<Classifier>((ref) => Classifier());

class Classifier {
  Future<Map<String, dynamic>> run({required String image}) async {
    ///prepare image to feed in to the classifire
    ///change the [224] to match with your new models input size.
    final imageInput = File(image);
    final decodedImage = img.decodeImage(await imageInput.readAsBytes());
    final resizedImage = img.copyResize(
      decodedImage!,
      width: 640,
      height: 640,
    );

    ///change the [224] to match with your new models input size.
    final imageBuffer =
        await _imageToByteListFloat32(resizedImage, 640, 127.5, 127.5);

    ///loading the tensorflow model
    final interpreter = await tfl.Interpreter.fromAsset(
      'assets/model/model.tflite',
      options: tfl.InterpreterOptions()..threads = 4,
    );
    final isolateInterpreter =
        await tfl.IsolateInterpreter.create(address: interpreter.address);
    await Future.delayed(const Duration(seconds: 1));

    ///preparing the output to match the output of the ML model
    ///Make sure to have a matching output
    var output0 = [List<List<double>>.filled(5, List<double>.filled(8400, 0))];
    Map<int, Object> output = {0: output0};

    ///running the ML on input image
    await isolateInterpreter.runForMultipleInputs([imageBuffer.buffer], output);

    final results = output[0] as List<List<List>>;

    ///load labels
    final List<String> labels = ['parasite'];

    List conf = List.empty(growable: true);

    for (var i = 0; i < results[0][4].length; i++) {
      if (results[0][4][i] > 0.15) {
        conf.add([
          results[0][0][i],
          results[0][1][i],
          results[0][2][i],
          results[0][3][i],
          results[0][4][i],
        ]);
      }
    }

    ///filter the recognitions with more than the given confidence value and apply non-max suppression
    final resultMap = analysedImage(
      image,
      conf,
    );

    ///closing the interpreter
    await isolateInterpreter.close();
    interpreter.close();
    return resultMap;
  }

  ///this function helps to decode image into UintBytes. This will be the input buffer of the ML model.
  Future<Uint8List> _imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) async {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  Map<String, dynamic> analysedImage(
      String imagePath, List<dynamic> firstObject,
      {double ioU = 0.4, double confidence = 0.15}) {
    int index = 0;
    String lable = 'Colony';
    List<Recognition> allRecognitions = List.empty(growable: true);

    for (var i = 0; i < firstObject.length; i++) {
      if (firstObject[i][4] > confidence) {
        //List fisrtLocation = firstObject.sublist(0,4);
        allRecognitions.add(Recognition(
            index,
            lable,
            firstObject[i][4],
            Rect.fromCenter(
              center: Offset(firstObject[i][0] * 640, firstObject[i][1] * 640),
              width: (firstObject[i][2] * 640),
              height: (firstObject[i][3] * 640),
            )));
        index++;
      }
    }

    final recognitions = nms(allRecognitions, ioU);

    final imageData = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageData);
    final aspectRatio = image!.height ~/ image.width;

    final imageInput = img.copyResize(
      image,
      width: 640,
      height: 640,
    );
    for (var i = 0; i < recognitions.length; i++) {
      Rect? rectangle = recognitions[i].location;
      // int x =
      //     ((rectangle!.right.toInt() + (rectangle.left - rectangle.right) ~/ 2))
      //         .abs();

      // int y =
      //     ((rectangle.top.toInt() + (rectangle.bottom - rectangle.top) ~/ 2))
      //         .abs();
      // int radius = ((rectangle.left - rectangle.right) / 2).abs().toInt();
      img.drawRect(imageInput,
          x1: rectangle.left.toInt(),
          y1: rectangle.top.toInt(),
          x2: rectangle.right.toInt(),
          y2: rectangle.bottom.toInt(),
          color: img.ColorRgba8(255, 0, 0, 255));
      // img.fillCircle(
      //   imageInput,
      //   x: x,
      //   y: y,
      //   radius: radius,
      //   color: img.ColorRgba8(255, 0, 0, 255),
      // );
    }
    // img.drawString(imageInput,
    //     "Count: ${recognitions.length.toString()}, Date: ${DateTime.now().toString().substring(0, 10)}",
    //     x: 10, y: 10, font: img.arial24, color: img.ColorRgb8(255, 255, 255));

    final outputImage =
        img.copyResize(imageInput, width: 640, height: 640 ~/ aspectRatio);

    final Map<String, dynamic> map = {
      "image": img.encodeJpg(outputImage),
      "count": recognitions.length
    };

    return map;
  }

  ///loading labels
  // Future<List<String>> _loadLabels() async {
  //   final labelTxt = await rootBundle.loadString('assets/model/labels.txt');
  //   final List<String> labels = labelTxt.split('\n');
  //   return labels;
  // }
}
