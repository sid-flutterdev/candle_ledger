import 'dart:async';
import '../models/goal.dart';
import '../repositories/goal_repository.dart';
import '../services/firebase_auth_service.dart';
import 'package:get/get.dart';

class GoalController extends GetxController {
  final GoalRepository _goalRepo = Get.find<GoalRepository>();
  final FirebaseAuthService _auth = Get.find<FirebaseAuthService>();

  var goals = <Goal>[].obs;
  StreamSubscription? _goalSub;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges.listen((user) {
      if (user != null) {
        _startListening();
        loadGoals();
      } else {
        _goalSub?.cancel();
        goals.clear();
      }
    });

    if (userId != null) {
      _startListening();
      loadGoals();
    }
  }

  @override
  void onClose() {
    _goalSub?.cancel();
    super.onClose();
  }

  void _startListening() {
    _goalSub?.cancel();
    _goalSub = _goalRepo.snapshots(userId ?? 'local_user').listen((data) {
      data.sort((a, b) {
        if (a.isDone == b.isDone) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return a.isDone ? 1 : -1;
      });
      goals.assignAll(data);
    });
  }

  String? get userId => _auth.currentUser?.uid;

  Future<void> loadGoals() async {
    if (userId != null) {
      final remoteGoals = await _goalRepo.syncFromFirestore(userId!);
      remoteGoals.sort((a, b) {
        if (a.isDone == b.isDone) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return a.isDone ? 1 : -1;
      });
      goals.assignAll(remoteGoals);
    }
  }

  Future<void> addGoal(String title, String? description) async {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _goalRepo.save(goal, userId ?? 'local_user');
    
    if (!goals.any((g) => g.id == goal.id)) {
      goals.add(goal);
      _sortGoalsLocally();
    }
  }

  Future<void> updateGoal(String id, String title, String? description) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updatedGoal = goals[index].copyWith(
        title: title,
        description: description,
      );
      await _goalRepo.save(updatedGoal, userId ?? 'local_user');
      goals[index] = updatedGoal;
      _sortGoalsLocally();
    }
  }

  Future<void> toggleGoal(String id) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updatedGoal = goals[index].copyWith(
        isDone: !goals[index].isDone,
      );
      await _goalRepo.save(updatedGoal, userId ?? 'local_user');
      goals[index] = updatedGoal;
      _sortGoalsLocally();
    }
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((g) => g.id == id);
    await _goalRepo.delete(id, userId ?? 'local_user');
  }

  void _sortGoalsLocally() {
    var list = goals.toList();
    list.sort((a, b) {
      if (a.isDone == b.isDone) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isDone ? 1 : -1;
    });
    goals.assignAll(list);
  }
}
