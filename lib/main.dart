import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mini_taskhub/auth/auth_service.dart';
import 'package:mini_taskhub/auth/signup_screen.dart';
import 'package:mini_taskhub/dashboard/profile_screen.dart';
import 'package:mini_taskhub/placeholder_screen.dart';
import 'package:mini_taskhub/splash_screen.dart';
import 'package:mini_taskhub/theme_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/task_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: "${dotenv.env['url']}",
    anonKey: "${dotenv.env['anonkey']}",
  );
  await GetStorage.init();
  Get.put(TaskService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authService = Get.put(AuthService());
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),

        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1F2630),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F2630),
            foregroundColor: Colors.white,
            elevation: 0,
          ),

        ),

        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashScreen()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/signup', page: () => const SignupScreen()),
          GetPage(name: '/dashboard', page: () => const DashboardScreen()),

          GetPage(name: '/profile', page: () => ProfileScreen()),
          GetPage(
            name: '/search',
            page: () => const PlaceholderScreen(title: 'Search'),
          ),
          GetPage(
            name: '/completed-tasks',
            page: () => const PlaceholderScreen(title: 'Completed Tasks'),
          ),
          GetPage(
            name: '/ongoing-projects',
            page: () => const PlaceholderScreen(title: 'Ongoing Projects'),
          ),
          GetPage(
            name: '/chat',
            page: () => const PlaceholderScreen(title: 'Chat'),
          ),
          GetPage(
            name: '/calendar',
            page: () => const PlaceholderScreen(title: 'Calendar'),
          ),
          GetPage(
            name: '/notifications',
            page: () => const PlaceholderScreen(title: 'Notifications'),
          ),
        ],
      ),
    );
  }
}
