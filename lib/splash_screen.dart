import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_taskhub/auth/auth_service.dart';

import 'dashboard/task_service.dart';

class SplashController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    authService.initAuthState();
  }

  void navigateBasedOnAuth() async {
    final isLoggedIn = authService.checkLoginStatus();
    print("Auth status on button press: $isLoggedIn");

    if (isLoggedIn) {
      await Get.find<TaskService>().fetchTasks();
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1B2229),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.04,
                  left: size.width * 0.06,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/Group 5.png',
                    width: size.width * 0.35,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                child: SizedBox(
                  height: size.height * 0.35,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/Rectangle 4.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      Positioned.fill(
                        child: Image.asset(
                          'assets/pana.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * .03),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Image.asset(
                  'assets/Manage your Task with DayTask.png',
                  width: size.width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.04,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: size.height * 0.065,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: controller.navigateBasedOnAuth,

                    child: const Text(
                      'Let\'s Start',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
