import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final String collectionName;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  BaseRepository(this.collectionName);

  // Helper to get the user-specific collection reference
  CollectionReference getCollection(String userId) {
    return firestore.collection('users').doc(userId).collection(collectionName);
  }

  // Fetch from Firestore subcollection
  Future<List<T>> syncFromFirestore(String userId) async {
    if (userId == 'local_user') return [];

    try {
      final snapshot = await getCollection(
        userId,
      ).get(const GetOptions(source: Source.serverAndCache))
       .timeout(const Duration(seconds: 8));

      return snapshot.docs
          .map((doc) => fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Real-time stream from Firestore
  Stream<List<T>> snapshots(String userId) {
    if (userId == 'local_user') {
      return Stream.value([]);
    }

    return getCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Write to Firestore subcollection
  Future<void> save(T item, String userId) async {
    if (userId == 'local_user') return;
    
    final id = getId(item);
    await getCollection(userId).doc(id).set(toFirestore(item, userId));
  }

  // Delete from Firestore subcollection
  Future<void> delete(String id, String userId) async {
    if (userId != 'local_user') {
      await getCollection(userId).doc(id).delete();
    }
  }

  // Abstract methods to be implemented by child classes
  String getId(T item);
  Map<String, dynamic> toFirestore(T item, String userId);
  T fromFirestore(Map<String, dynamic> map);
}

