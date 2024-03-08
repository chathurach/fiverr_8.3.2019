import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parasite_detector_still/functions/classifier.dart';

import '../enum/image_source.dart';

import 'image_source_selector.dart';

final getImage = FutureProvider<Map<String, dynamic>>((ref) async {
  final ImagePicker picker = ImagePicker();

  XFile? file;

  final selected = ref.watch(selectedImageSource);

  switch (selected) {
    case ImageSourceSelector.camera:
      file = await picker.pickImage(
        source: ImageSource.camera,
      );
      break;
    case ImageSourceSelector.gallery:
      file = await picker.pickImage(
        source: ImageSource.gallery,
      );
      break;
  }
  File? croppedFile;
  if (file != null) {
    croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      cropStyle: CropStyle.rectangle,
      androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true),
    );
  }
  if (croppedFile != null) {
    ///run the ml model
    final map = await ref.watch(classifire).run(image: croppedFile.path);

    return map;
  } else {
    return {};
  }
});
