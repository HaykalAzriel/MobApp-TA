import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageState with ChangeNotifier {
  File? _hostImage;
  File? _watermarkImage;

  File? get hostImage => _hostImage;
  File? get watermarkImage => _watermarkImage;

  void setHostImage(File image) {
    _hostImage = image;
    notifyListeners();
  }

  void setWatermarkImage(File image) {
    _watermarkImage = image;
    notifyListeners();
  }
}
