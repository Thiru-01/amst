import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ImageController extends GetxController {
  RxString imagepath = ''.obs;
  Rx<TextEditingController> textController = TextEditingController().obs;
  void makePath(String path) {
    imagepath.value = path;
  }
}
