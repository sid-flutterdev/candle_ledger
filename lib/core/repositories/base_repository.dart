import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

abstract class BaseRepository<T> {
  final Box<T> box;
  final String collectionName;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  BaseRepository({required this.box, required this.collectionName});

  // Helper to get the user-specific collection reference
  CollectionReference getCollection(String userId) {
    return firestore.collection('users').doc(userId).collection(collectionName);
  }

  // Load from Hive for instant UI
  List<T> getAllLocal() => box.values.toList();

  // Fetch from Firestore subcollection and update Hive
  Future<List<T>> syncFromFirestore(String userId) async {
    if (userId == 'local_user') return getAllLocal();

    try {
      final snapshot = await getCollection(
        userId,
      ).get(const GetOptions(source: Source.serverAndCache));

      final List<T> remoteData = snapshot.docs
          .map((doc) => fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Update local Hive cache with remote data
      for (var item in remoteData) {
        await box.put(getId(item), item);
      }

      return getAllLocal();
    } catch (e) {
      return getAllLocal();
    }
  }

  // Real-time stream from Firestore
  Stream<List<T>> snapshots(String userId) {
    if (userId == 'local_user') {
      // Just return local changes
      return box.watch().map((_) => getAllLocal());
    }

    return getCollection(userId).snapshots().asyncMap((snapshot) async {
      final List<T> remoteData = snapshot.docs
          .map((doc) => fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Sync Hive with Firestore silently
      for (var item in remoteData) {
        await box.put(getId(item), item);
      }

      return remoteData;
    });
  }

  // Migrate any data that was created while logged out to the user's account
  Future<void> migrateLocalData(String userId) async {
    if (userId == 'local_user') return;

    final localItems = getAllLocal();
    for (var item in localItems) {
      // Push every local item to Firestore
      await getCollection(userId).doc(getId(item)).set(toFirestore(item, userId));
    }
  }

  // Write to both Hive and Firestore subcollection
  Future<void> save(T item, String userId) async {
    final id = getId(item);

    // 1. Update Hive instantly for snappy UI
    await box.put(id, item);

    // 2. Push to Firestore subcollection if authenticated
    if (userId != 'local_user') {
      await getCollection(userId).doc(id).set(toFirestore(item, userId));
    }
  }

  // Delete from both Hive and Firestore subcollection
  Future<void> delete(String id, String userId) async {
    await box.delete(id);
    if (userId != 'local_user') {
      await getCollection(userId).doc(id).delete();
    }
  }

  // Abstract methods to be implemented by child classes
  String getId(T item);
  Map<String, dynamic> toFirestore(T item, String userId);
  T fromFirestore(Map<String, dynamic> map);
}
