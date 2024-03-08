import 'dart:math';
import 'dart:ui';

import '../models/recognitions.dart';

///this module filter the recognitions with the iou
///which aggregate the bounding boxes and remove unwanted boxes.

List<Recognition> nms(List<Recognition> recognitions, double iouThreshold) {
  List<Recognition> result = [];

  // Sort recognitions by confidence in descending order
  recognitions.sort((a, b) => b.score.compareTo(a.score));

  for (int i = 0; i < recognitions.length; i++) {
    Recognition current = recognitions[i];
    bool keep = true;

    for (int j = 0; j < result.length; j++) {
      Recognition previous = result[j];

      double intersection =
          calculateIntersection(current.location, previous.location);
      double union =
          calculateUnion(current.location, previous.location, intersection);
      double iou = intersection / union;

      if (iou > iouThreshold) {
        keep = false;
        break;
      }
    }

    if (keep) {
      result.add(current);
    }
  }

  return result;
}

double calculateIntersection(Rect a, Rect b) {
  double left = max(a.left, b.left);
  double top = max(a.top, b.top);
  double right = min(a.right, b.right);
  double bottom = min(a.bottom, b.bottom);

  if (left >= right || top >= bottom) {
    return 0.0;
  }

  return (right - left) * (bottom - top);
}

double calculateUnion(Rect a, Rect b, double intersection) {
  double areaA = (a.right - a.left) * (a.bottom - a.top);
  double areaB = (b.right - b.left) * (b.bottom - b.top);

  return areaA + areaB - intersection;
}
