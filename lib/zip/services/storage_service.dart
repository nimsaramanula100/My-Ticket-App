// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ─── Pick Image from Gallery ────────────────────────────────
  Future<File?> pickImageFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 800,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // ─── Pick Image from Camera ─────────────────────────────────
  Future<File?> pickImageFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 800,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // ─── Upload Event Banner ────────────────────────────────────
  Future<String> uploadEventBanner(File file, String eventId) async {
    final ref = _storage.ref().child('events/$eventId/banner.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  // ─── Upload Organizer Profile Photo ────────────────────────
  Future<String> uploadOrganizerPhoto(File file, String organizerId) async {
    final ref = _storage.ref().child('organizers/$organizerId/profile.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  // ─── Upload User Avatar ─────────────────────────────────────
  Future<String> uploadUserAvatar(File file, String userId) async {
    final ref = _storage.ref().child('users/$userId/avatar.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  // ─── Delete File ────────────────────────────────────────────
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }

  // ─── Upload with Progress ───────────────────────────────────
  Future<String> uploadWithProgress(
    File file,
    String path, {
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref().child(path);
    final task = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

    task.snapshotEvents.listen((snapshot) {
      if (onProgress != null) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      }
    });

    final snap = await task;
    return await snap.ref.getDownloadURL();
  }
}
