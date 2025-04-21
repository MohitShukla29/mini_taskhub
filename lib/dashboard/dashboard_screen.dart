import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mini_taskhub/dashboard/add_task.dart';
import 'package:mini_taskhub/dashboard/task_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../auth/auth_service.dart';
import '../models/task_model.dart';
import '../theme_controller.dart';
import 'edit_task.dart';

class DashboardController extends GetxController {
  final username = "".obs;
  final selectedIndex = 0.obs;
  final taskService = Get.find<TaskService>();

  final completedTasks = <Task>[].obs;
  final ongoingProjects = <Task>[].obs;
  final isLoading = false.obs;
  final themeController = Get.find<ThemeController>();

  @override
  void onInit() {
    super.onInit();
    refreshTasks();
    loadUsername();
  }

  void loadUsername() {
    final authService = Get.find<AuthService>();
    username.value = authService.getCurrentUserName() ?? "User";
  }

  Future<void> refreshTasks() async {
    isLoading.value = true;
    try {
      await taskService.fetchTasks();
      completedTasks.value = taskService.completedTasks;
      ongoingProjects.value = taskService.ongoingProjects;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    isLoading.value = true;
    try {
      await taskService.deleteTask(taskId);
      await refreshTasks();
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    isLoading.value = true;
    try {
      await taskService.markTaskAsCompleted(taskId);
      await refreshTasks();
      Get.snackbar(
        'Success',
        'Task marked as completed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showEditTaskModal(Task task) {
    Get.bottomSheet(
      EditTaskScreen(task: task),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2A2F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  void navigateToPage(int index) {
    switch (index) {
      case 0:
        break;
      case 1: // Chat
        Get.toNamed('/chat');
        break;
      case 2: // Add - will be handled separately
        break;
      case 3: // Calendar
        Get.toNamed('/calendar');
        break;
      case 4: // Notification
        Get.toNamed('/notifications');
        break;
    }
  }

  void showAddTaskModal() {
    Get.bottomSheet(
      const CreateTaskScreen(),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2A2F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  void navigateToProfile() {
    Get.toNamed('/profile');
  }

  void navigateToSearch() {
    Get.toNamed('/search');
  }

  void seeAllCompletedTasks() {
    Get.toNamed('/completed-tasks');
  }

  void seeAllOngoingProjects() {
    Get.toNamed('/ongoing-projects');
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.08;

    return Obx(() => Scaffold(
      backgroundColor: controller.themeController.isDarkMode.value
          ? const Color(0xFF1B2229)
          : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            _buildSearchBar(context, controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshTasks,
                color: Colors.amber,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSectionHeader(
                        "Completed Tasks",
                        true,
                        context,
                        controller,
                        onSeeAll: controller.seeAllCompletedTasks,
                      ),
                      _buildCompletedTasksGrid(context),
                      _buildSectionHeader(
                        "Ongoing Projects",
                        true,
                        context,
                        controller,
                        onSeeAll: controller.seeAllOngoingProjects,
                      ),
                      _buildOngoingProjectsList(context),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigationBar(context, controller),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildHeader(BuildContext context, DashboardController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.amber[400],
                  ),
                ),
                Obx(
                  () => Text(
                    controller.username.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: controller.themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/Ellipse 36.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: controller.navigateToProfile,
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, DashboardController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.navigateToSearch,
              child: Container(
                height: isSmallScreen ? 45 : 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: controller.themeController.isDarkMode.value
                      ? const Color(0xFF2A3642)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: isSmallScreen ? 22 : 26,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Search tasks',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: isSmallScreen ? 45 : 55,
            height: isSmallScreen ? 45 : 55,
            decoration: BoxDecoration(
              color: Colors.amber[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.tune,
                color: Colors.black,
                size: isSmallScreen ? 22 : 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool showAll,
    BuildContext context,
    DashboardController controller, {
    VoidCallback? onSeeAll,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: controller.themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          if (showAll)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.amber[400],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final cardWidth = screenWidth * 0.7;
    final isSmallScreen = screenWidth < 360;
    final controller = Get.find<DashboardController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: isSmallScreen ? 200 : 230,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        );
      }

      if (controller.completedTasks.isEmpty) {
        return SizedBox(
          height: isSmallScreen ? 200 : 230,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.grey,
                  size: isSmallScreen ? 48 : 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed tasks yet',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: isSmallScreen ? 200 : 230,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: controller.completedTasks.length,
          itemBuilder: (context, index) {
            final task = controller.completedTasks[index];
            final color =
                index % 2 == 0 ? Colors.amber[300]! : const Color(0xFF2A3642);

            return Dismissible(
              key: Key(task.id.toString()),
              direction: DismissDirection.vertical,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF2A3642),
                      title: const Text(
                        'Confirm Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this task?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.amber[400]),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                controller.deleteTask(task.id.toString());
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onLongPress:
                      () => _showTaskOptions(context, task, controller),
                  child: _buildCompletedTaskCard(
                    task.title,
                    color,
                    task.teamMemberIds.length,
                    task.progress,
                    context,
                    cardWidth,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _showTaskOptions(
    BuildContext context,
    Task task,
    DashboardController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2A2F),
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Task',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.deleteTask(task.id.toString());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompletedTaskCard(
    String title,
    Color bgColor,
    int teamSize,
    double progress,
    BuildContext context,
    double cardWidth,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color:
                    bgColor == Colors.amber[300] ? Colors.black : Colors.white,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'Team members',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color:
                          bgColor == Colors.amber[300]
                              ? Colors.black
                              : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: isSmallScreen ? 24 : 30,
                    width: (teamSize * (isSmallScreen ? 16 : 20)) + 10,
                    child: Stack(
                      children: List.generate(teamSize, (index) {
                        return Positioned(
                          left:
                              index *
                              (isSmallScreen ? 16 : 20), // adjust overlap
                          child: Container(
                            width: isSmallScreen ? 24 : 30,
                            height: isSmallScreen ? 24 : 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  [
                                    Colors.amber[300],
                                    Colors.redAccent,
                                    Colors.blue[300],
                                    Colors.green[300],
                                    Colors.purple[300],
                                  ][index % 5],
                              border: Border.all(color: bgColor, width: 2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color:
                        bgColor == Colors.amber[300]
                            ? Colors.black
                            : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            bgColor == Colors.amber[300]
                                ? Colors.black.withOpacity(0.2)
                                : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: (cardWidth - (isSmallScreen ? 24 : 32)) * progress,
                      decoration: BoxDecoration(
                        color:
                            bgColor == Colors.amber[300]
                                ? Colors.black
                                : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '100%',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color:
                          bgColor == Colors.amber[300]
                              ? Colors.black
                              : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingProjectsList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final controller = Get.find<DashboardController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        );
      }

      if (controller.ongoingProjects.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 32,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_outline, color: Colors.grey, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No ongoing projects',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to create a new task',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.ongoingProjects.length,
          itemBuilder: (context, index) {
            final task = controller.ongoingProjects[index];
            final dueDate = DateFormat('dd MMM').format(task.dueDate);

            return Dismissible(
              key: Key(task.id.toString()),
              direction: DismissDirection.horizontal,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.check, color: Colors.white),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: controller.themeController.isDarkMode.value
                            ? const Color(0xFF2A3642)
                            : Colors.white,
                        title: Text(
                          'Confirm Delete',
                          style: TextStyle(color: controller.themeController.isDarkMode.value
                              ? Colors.white
                              : Colors.black,),
                        ),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.amber[400]),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else if (direction == DismissDirection.startToEnd) {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF2A3642),
                        title: const Text(
                          'Mark as Completed',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Do you want to mark this task as completed?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.amber[400]),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Complete',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                return false;
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  controller.deleteTask(task.id.toString());
                } else if (direction == DismissDirection.startToEnd) {
                  controller.markTaskAsCompleted(task.id.toString());
                }
              },
              child: GestureDetector(
                onLongPress:
                    () => _showOngoingTaskOptions(context, task, controller),
                child: _buildOngoingProjectCard(
                  task.title,
                  task.teamMemberIds.length,
                  dueDate,
                  task.progress,
                  context,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _showOngoingTaskOptions(
    BuildContext context,
    Task task,
    DashboardController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2A2F),
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text(
                'Mark as Completed',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.markTaskAsCompleted(task.id.toString());
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text(
                'Edit Task',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.showEditTaskModal(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Task',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.deleteTask(task.id.toString());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOngoingProjectCard(
    String title,
    int teamSize,
    String dueDate,
    double progress,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final controller = Get.find<DashboardController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: controller.themeController.isDarkMode.value
            ? const Color(0xFF2A3642)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (progress > 0)
                CircularPercentIndicator(
                  radius: isSmallScreen ? 25 : 30,
                  lineWidth: isSmallScreen ? 6 : 8,
                  progressColor: Colors.amber[400],
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  percent: progress,
                  center: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamMembers(teamSize, isSmallScreen),
                    if (dueDate.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDueDate(dueDate, isSmallScreen),
                    ],
                  ],
                );
              } else {
                return Row(
                  children: [
                    _buildTeamMembers(teamSize, isSmallScreen),
                    if (dueDate.isNotEmpty) ...[
                      const Spacer(),
                      _buildDueDate(dueDate, isSmallScreen),
                    ],
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembers(int teamSize, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team members',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            teamSize,
            (index) => Container(
              margin: EdgeInsets.only(right: index == teamSize - 1 ? 0 : 4),
              width: isSmallScreen ? 24 : 30,
              height: isSmallScreen ? 24 : 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    [
                      Colors.amber[300],
                      Colors.blue[300],
                      Colors.redAccent,
                    ][index % 3],
                border: Border.all(color: const Color(0xFF2A3642), width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDate(String dueDate, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due on :',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dueDate,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    DashboardController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      height: isSmallScreen ? 60 : 70,
      color: controller.themeController.isDarkMode.value
          ? const Color(0xFF1C252D)
          : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            Icons.home,
            'Home',
            true,
            isSmallScreen,
            () => controller.navigateToPage(0),
          ),
          _buildNavItem(
            context,
            Icons.chat_bubble_outline,
            'Chat',
            false,
            isSmallScreen,
            () => controller.navigateToPage(1),
          ),
          _buildAddButton(context, controller, isSmallScreen),
          _buildNavItem(
            context,
            Icons.calendar_today,
            'Calendar',
            false,
            isSmallScreen,
            () => controller.navigateToPage(3),
          ),
          _buildNavItem(
            context,
            Icons.notifications_none,
            'Notification',
            false,
            isSmallScreen,
            () => controller.navigateToPage(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    bool isSmallScreen,
    VoidCallback onTap,
  ) {
    final showLabel =
        !isSmallScreen || (MediaQuery.maybeOf(context)?.size.width ?? 0) > 320;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.amber[400] : Colors.grey,
            size: isSmallScreen ? 20 : 24,
          ),
          if (showLabel) ...[
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.amber[400] : Colors.grey,
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    DashboardController controller,
    bool isSmallScreen,
  ) {
    return Container(
      width: isSmallScreen ? 40 : 50,
      height: isSmallScreen ? 40 : 50,
      decoration: BoxDecoration(
        color: Colors.amber[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: IconButton(
          onPressed: controller.showAddTaskModal,
          icon: Icon(
            Icons.add,
            color: Colors.black,
            size: isSmallScreen ? 24 : 30,
          ),
        ),
      ),
    );
  }
}

extension MediaQueryNullSafety on BuildContext {
  static MediaQueryData? get currentOrNull {
    try {
      return MediaQuery.maybeOf(Get.context!);
    } catch (e) {
      return null;
    }
  }
}
