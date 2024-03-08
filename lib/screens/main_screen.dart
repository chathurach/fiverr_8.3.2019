import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parasite_detector_still/functions/classifier.dart';

import '../enum/image_source.dart';
import '../functions/image_picker.dart';
import '../functions/image_source_selector.dart';

import '../models/screen_params.dart';
import 'result_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parasite Detector'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(getImage);
                  ref.invalidate(classifire);
                  ref.read(selectedImageSource.notifier).state =
                      ImageSourceSelector.camera;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ResultPage(),
                    ),
                  );
                },
                child: const Text('Camera'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(getImage);
                  ref.invalidate(classifire);
                  ref.read(selectedImageSource.notifier).state =
                      ImageSourceSelector.gallery;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ResultPage(),
                    ),
                  );
                },
                child: const Text('Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
