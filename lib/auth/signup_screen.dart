import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mini_taskhub/auth/auth_service.dart';

class SignupController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final isAgreed = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleAgreement() {
    isAgreed.value = !isAgreed.value;
  }

  Future<void> signup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isAgreed.value) {
      Get.snackbar(
        'Error',
        'Please agree to the terms and conditions',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await authService.signUpWithEmailPassword(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
      );

      isLoading.value = false;

      if (response != null) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar(
          'Signup Failed',
          'Failed to create account. Please try again.',
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        'Error',
        'Signup failed: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1B2229),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.02,
                    bottom: size.height * 0.02,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/Group 5.png',
                        width: size.width * 0.25,
                        height: size.width * 0.15,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              Text(
                'Create your account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              Text(
                'Full Name',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B45),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TextField(
                  controller: controller.nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.025),

              Text(
                'Email Address',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B45),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TextField(
                  controller: controller.emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.025),

              Text(
                'Password',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B45),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey[400],
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Baseline(
                    baseline: 27,
                    baselineType: TextBaseline.alphabetic,
                    child: Obx(
                      () => Checkbox(
                        value: controller.isAgreed.value,
                        onChanged: (value) {
                          controller.toggleAgreement();
                        },
                        checkColor: Colors.black,
                        activeColor: const Color(0xFFFFCC55),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'I have read and agreed to DayTask ',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        children: const [
                          TextSpan(
                            text: '(privacy policy terms and condition)',
                            style: TextStyle(
                              color: Color(0xFFFFCC55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: size.height * 0.065,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed:
                        controller.isLoading.value ? null : controller.signup,
                    child:
                        controller.isLoading.value
                            ? CircularProgressIndicator(color: Colors.black)
                            : const Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[700], thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[700], thickness: 1),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.google, color: Colors.grey[400]),
                      const SizedBox(width: 12),
                      const Text(
                        'Google',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      children: const [
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            color: Color(0xFFFFCC55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
