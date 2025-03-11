import 'package:get/get.dart';

class CategoryController extends GetxController {
  RxString _category = ''.obs;

  String get categoryValue => _category.value;

  void updateCategoryValue(String value) {
    _category.value = value;
  }

  RxString  get _title => ''.obs;
  String get title => _title.value;
  set title(String value) => _title.value = value;
  void updateTitle(String value) {
    _title.value = value;
  }


}

