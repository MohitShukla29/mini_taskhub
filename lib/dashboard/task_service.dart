import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../models/task_model.dart';

class TaskService extends GetxService {
  final supabase = Supabase.instance.client;
  final tasks = <Task>[].obs;
  final completedTasks = <Task>[].obs;
  final ongoingProjects = <Task>[].obs;

  Future<TaskService> init() async {
    return this;
  }

  Future<void> fetchTasks() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('due_date', ascending: true);

      final fetchedTasks =
          (response as List).map((taskJson) => Task.fromMap(taskJson)).toList();

      tasks.value = fetchedTasks;
      completedTasks.value =
          fetchedTasks.where((task) => task.isCompleted).toList();
      ongoingProjects.value =
          fetchedTasks.where((task) => !task.isCompleted).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      throw e;
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> teamMemberIds,
    required double progress,
    required bool isCompleted,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final task = Task(
        title: title,
        description: description,
        dueDate: dueDate,
        teamMemberIds: teamMemberIds,
        progress: progress,
        isCompleted: isCompleted,
        userId: userId,
      );

      final response =
          await supabase.from('tasks').insert(task.toMap()).select().single();

      final newTask = Task.fromMap(response);
      tasks.add(newTask);
      ongoingProjects.add(newTask);
    } catch (e) {
      print('Error creating task: $e');
      throw e;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await supabase
          .from('tasks')
          .update(task.toMap())
          .eq('id', task.id as Object);

      await fetchTasks();
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await supabase.from('tasks').delete().eq('id', taskId);

      await fetchTasks();
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);

      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        teamMemberIds: task.teamMemberIds,
        progress: 1.0,
        isCompleted: true,
        userId: task.userId,
      );

      await updateTask(updatedTask);
    } catch (e) {
      print('Error marking task as completed: $e');
      throw e;
    }
  }
}
