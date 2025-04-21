import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/task_service.dart';
import '../theme_controller.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GetStorage _storage = GetStorage();

  final Rx<bool> _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  void initAuthState() {
    checkLoginStatus();
    print("Auth state initialized: ${_isLoggedIn.value}");
  }

  bool checkLoginStatus() {
    final token = _storage.read('token');
    final currentSession = _supabase.auth.currentSession;

    if (currentSession != null && !currentSession.isExpired && token == null) {
      _storage.write('token', currentSession.accessToken);
    }

    _isLoggedIn.value =
        (currentSession != null && !currentSession.isExpired) || token != null;
    return _isLoggedIn.value;
  }

  Future<AuthResponse?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _storage.write('token', response.session!.accessToken);
        _isLoggedIn.value = true;
        await Get.find<TaskService>().fetchTasks();
        return response;
      } else {
        print('Login failed: No session returned');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<AuthResponse?> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.session != null) {
        _storage.write('token', response.session!.accessToken);
        _storage.write('username', name);
        _isLoggedIn.value = true;
        await Get.find<TaskService>().fetchTasks();
      }
      return response;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _storage.remove('token');
      _isLoggedIn.value = false;
      Get.find<ThemeController>().resetTheme();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  String? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    return session?.user.email;
  }

  String? getCurrentUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['name'] as String?;
  }
}
