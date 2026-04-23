import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a trade screenshot to Firebase Storage.
  /// Returns the download URL on success, or null on failure.
  Future<String?> uploadTradeScreenshot({
    required String userId,
    required String tradeId,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return null;
      }

      final ref = _storage.ref().child(
        'trade_screenshots/$userId/$tradeId.jpg',
      );

      // Metadata for better organization
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId, 'tradeId': tradeId},
      );

      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Deletes a single screenshot from Firebase Storage.
  Future<void> deleteScreenshot(String userId, String tradeId) async {
    try {
      final ref = _storage.ref().child(
        'trade_screenshots/$userId/$tradeId.jpg',
      );
      await ref.delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Deletes all screenshots for a specific user from Firebase Storage.
  Future<void> deleteAllUserMedia(String userId) async {
    try {
      final listResult = await _storage
          .ref()
          .child('trade_screenshots/$userId')
          .listAll();
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      print("StorageService: Error deleting user media: $e");
    }
  }
}
