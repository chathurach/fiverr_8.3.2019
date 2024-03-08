import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enum/image_source.dart';

final selectedImageSource =
    StateProvider<ImageSourceSelector>((ref) => ImageSourceSelector.gallery);
