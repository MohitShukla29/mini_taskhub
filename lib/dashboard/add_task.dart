import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mini_taskhub/dashboard/task_service.dart';

import 'dashboard_screen.dart';

class CreateTaskController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();
  final selectedTeamMembers = <String>[].obs;
  final selectedDate = Rx<DateTime?>(null);
  final isLoading = false.obs;

  final teamMembers = [
    {'id': '1', 'name': 'Team Member 1', 'color': Colors.amber},
    {'id': '2', 'name': 'Team Member 2', 'color': Colors.blue},
    {'id': '3', 'name': 'Team Member 3', 'color': Colors.red},
    {'id': '4', 'name': 'Team Member 4', 'color': Colors.green},
    {'id': '5', 'name': 'Team Member 5', 'color': Colors.purple},
  ];

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
    super.onClose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dueDateController.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  void toggleTeamMember(String id) {
    if (selectedTeamMembers.contains(id)) {
      selectedTeamMembers.remove(id);
    } else {
      selectedTeamMembers.add(id);
    }
  }

  Future<void> createTask() async {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Task title is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final taskService = Get.find<TaskService>();

      await taskService.createTask(
        title: titleController.text,
        description: descriptionController.text,
        dueDate:
            selectedDate.value ?? DateTime.now().add(const Duration(days: 7)),
        teamMemberIds: selectedTeamMembers,
        progress: 0.0,
        isCompleted: false,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      final dashboardController = Get.find<DashboardController>();
      dashboardController.refreshTasks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateTaskController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      height: screenHeight * 0.9,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2A2F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create New Task',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Task Title'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter task title',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF2A3642),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter task description',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF2A3642),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Due Date'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => controller.selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller.dueDateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Select due date',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFF2A3642),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.all(
                            isSmallScreen ? 12 : 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Team Members'),
                  const SizedBox(height: 16),
                  _buildTeamMembersSelector(controller),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 48 : 56,
              child: ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                          'Create Task',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTeamMembersSelector(CreateTaskController controller) {
    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            controller.teamMembers.map((member) {
              final isSelected = controller.selectedTeamMembers.contains(
                member['id'],
              );

              return GestureDetector(
                onTap:
                    () => controller.toggleTeamMember(member['id'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? member['color'] as Color
                            : const Color(0xFF2A3642),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.transparent
                              : member['color'] as Color,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    member['name'] as String,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.black : member['color'] as Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
