// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:parasite_detector_app/models/recognitions.dart';

// import '../models/screen_params.dart';
// import 'classifier.dart';

// ///make sure that the model is not loading
// final loadingProvider = StateProvider<bool>((ref) => false);

// ///holds the results of each inference
// final resultProvider =
//     StateProvider.autoDispose<List<Recognition>?>((ref) => null);

// ///This riverpod provider is use to initialze the camera and pre load the model.
// ///model loading is happened only once
// final cameraProvider = FutureProvider<CameraController>((ref) async {
//   ///loading the model appropriate model.
//   await ref.read(classifire).load();

//   ///initialize the camera
//   final cameras = await availableCameras();

//   ///use the front camera[1]. if needed, back camera[0]
//   final camera = cameras[0];
//   final controller = CameraController(
//     camera,
//     ResolutionPreset.medium,
//     enableAudio: false,
//   );
//   await controller.initialize();
//   await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
//   ScreenParams.previewSize = controller.value.previewSize!;
//   return controller;
// });

// ///This riverpod provider provides the stream of data from the model.
// final imageStreamProvider = StreamProvider.autoDispose<dynamic>((ref) async* {
//   ///get the pre initialized model
//   final classifireInstance = ref.read(classifire);

//   ///get the pre initialized camera instance
//   final camera = await ref.watch(cameraProvider.future);

//   ///when app closes, dispose the model and the camera instance
//   ref.onDispose(() async {
//     await classifireInstance.close();
//     await camera.stopImageStream();
//   });

//   ///result preparation with image stream
//   yield camera.startImageStream((image) async {
//     ///if the model is not busy;
//     if (!ref.read(loadingProvider)) {
//       ///set => model is busy
//       ref.read(loadingProvider.notifier).state = true;

//       ///get the result from the model
//       final resultNow = await classifireInstance.run(image: image);
//       ref.read(resultProvider.notifier).state = resultNow;

//       ///release the model
//       ref.read(loadingProvider.notifier).state = false;
//     }
//   });
// });
