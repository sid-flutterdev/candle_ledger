import '../models/goal.dart';
import 'base_repository.dart';

class GoalRepository extends BaseRepository<Goal> {
  GoalRepository() : super('goals');

  @override
  Goal fromFirestore(Map<String, dynamic> map) {
    return Goal.fromFirestore(map);
  }

  @override
  String getId(Goal item) => item.id;

  @override
  Map<String, dynamic> toFirestore(Goal item, String userId) {
    return item.toFirestore(userId);
  }
}
