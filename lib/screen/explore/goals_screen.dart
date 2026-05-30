
import 'package:candle_ledger/core/controllers/goal_controller.dart';
import 'package:candle_ledger/core/models/goal.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalController _goalController = Get.find<GoalController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Goals",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => _showAddEditGoalSheet(),
          ),
        ],
      ),
      body: Obx(() {
        if (_goalController.goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.track_changes_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Text(
                  "No goals set yet.",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditGoalSheet(),
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: Text(
                    "Add Goal",
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _goalController.goals.length,
          itemBuilder: (context, index) {
            final goal = _goalController.goals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGoalTile(goal),
            );
          },
        );
      }),
    );
  }

  Widget _buildGoalTile(Goal goal) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _goalController.toggleGoal(goal.id),
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: goal.isDone ? Colors.blueAccent : Colors.transparent,
                border: Border.all(
                  color: goal.isDone ? Colors.blueAccent : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: goal.isDone
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: GoogleFonts.outfit(
                    color: goal.isDone ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: goal.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    goal.description!,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      decoration: goal.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, color: Colors.white.withValues(alpha: 0.5)),
            color: const Color(0xFF2C2C2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') {
                _showAddEditGoalSheet(goal: goal);
              } else if (value == 'delete') {
                _goalController.deleteGoal(goal.id);
                Get.snackbar(
                  "Goal Deleted",
                  "The goal was removed successfully.",
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      "Edit",
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      "Delete",
                      style: GoogleFonts.outfit(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditGoalSheet({Goal? goal}) {
    final titleController = TextEditingController(text: goal?.title);
    final descController = TextEditingController(text: goal?.description);
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal == null ? "New Goal" : "Edit Goal",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Title Field
                Text(
                  "Title",
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "E.g. Reach \$10k balance",
                    hintStyle: GoogleFonts.outfit(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                
                // Description Field
                Text(
                  "Description (Optional)",
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descController,
                  style: GoogleFonts.outfit(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Add some details...",
                    hintStyle: GoogleFonts.outfit(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (goal == null) {
                          _goalController.addGoal(
                            titleController.text.trim(),
                            descController.text.trim().isEmpty ? null : descController.text.trim(),
                          );
                        } else {
                          _goalController.updateGoal(
                            goal.id,
                            titleController.text.trim(),
                            descController.text.trim().isEmpty ? null : descController.text.trim(),
                          );
                        }
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Save Goal",
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
