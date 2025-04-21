import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read('isDarkMode') ?? false;
    _applyTheme();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _applyTheme();
    _storage.write('isDarkMode', isDarkMode.value);
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  void resetTheme() {
    _storage.remove('isDarkMode');
    isDarkMode.value = true; // Set to default theme (light)
    _applyTheme();
  }
}