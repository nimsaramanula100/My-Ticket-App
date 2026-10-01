// lib/services/storage_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// StorageService | ගොනු ගබඩා සේවා පන්තිය
// Manages media files: picking images from gallery/camera and uploading to Firebase Storage.
// මාධ්‍ය ගොනු කළමනාකරණය: ගැලරියෙන්/කැමරාවෙන් ඡායාරූප තෝරා ගැනීම සහ Firebase Storage වෙත උඩුගත කිරීම.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  // Instance references for Firebase Storage & device image picker
  // Firebase Storage සහ දේශීය ඡායාරූප තෝරන්නා (Image Picker) සඳහා වන වස්තූන්
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ─── pickImageFromGallery: Select image from device gallery | ගැලරියෙන් ඡායාරූපයක් තේරීම ──
  // Compresses quality and limits resolution to optimize storage usage.
  // ගබඩා ඉඩ ඉතිරි කර ගැනීමට ඡායාරූපයේ ගුණාත්මකභාවය සහ විභේදනය සීමා කරයි.
  Future<File?> pickImageFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compresses to 80% quality | 80% දක්වා ගුණාත්මකභාවය සම්පීඩනය කරයි
      maxWidth: 1200,   // Max width constraint | උපරිම පළල සීමාව
      maxHeight: 800,   // Max height constraint | උපරිම උස සීමාව
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // ─── pickImageFromCamera: Shoot a photo using device camera | කැමරාවෙන් ඡායාරූපයක් ගැනීම ──
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

  // ─── uploadEventBanner: Upload flyer for an event | සිදුවීම් බැනරයක් උඩුගත කිරීම ──────────
  // Saves file to events/{eventId}/banner.jpg and returns public HTTPS URL.
  // events/{eventId}/banner.jpg ස්ථානයට ගොනුව සුරකා එහි පොදු සබැඳිය (URL) ලබා දෙයි.
  Future<String> uploadEventBanner(File file, String eventId) async {
    final ref = _storage.ref().child('events/$eventId/banner.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'), // Explicit content header | ගොනු වර්ගයේ ශීර්ෂකය සකසයි
    );
    return await task.ref.getDownloadURL();
  }

  // ─── uploadOrganizerPhoto: Upload organizer profile photo | සංවිධායක ඡායාරූපය උඩුගත කිරීම ──
  Future<String> uploadOrganizerPhoto(File file, String organizerId) async {
    final ref = _storage.ref().child('organizers/$organizerId/profile.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  // ─── uploadUserAvatar: Upload app user profile image | පරිශීලක පැතිකඩ රූපය උඩුගත කිරීම ────
  Future<String> uploadUserAvatar(File file, String userId) async {
    final ref = _storage.ref().child('users/$userId/avatar.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  // ─── deleteFile: Remove a file from cloud storage | ගොනුවක් මකා දැමීම ─────────────────────
  // Deletes using raw download HTTPS link reference.
  // බාගත කිරීමේ HTTPS සබැඳිය යොදාගෙන ගොනුව cloud ගබඩාවෙන් මකා දමයි.
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // Ignore errors if the file has already been deleted
      // ගොනුව දැනටමත් මකා දමා ඇත්නම් ඇතිවන දෝෂ නොසලකා හරියි
    }
  }

  // ─── uploadWithProgress: Upload file with a progress hook | ප්‍රගතිය නිරීක්ෂණය කරමින් උඩුගත කිරීම ──
  // Periodically calls onProgress callback with fraction of bytes loaded.
  // ගොනුව උඩුගත වන අතරතුර එහි ප්‍රගති ප්‍රතිශතය onProgress ශ්‍රිතය මඟින් සපයයි.
  Future<String> uploadWithProgress(
    File file,
    String path, {
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref().child(path);
    final task = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

    // Listen to transfer status events | දත්ත මාරු කිරීමේ තත්ත්ව සජීවීව ශ්‍රවණය කිරීම
    task.snapshotEvents.listen((snapshot) {
      if (onProgress != null) {
        // Calculate fraction: transferred bytes / total bytes
        // මාරු කළ බයිට් ගණන මුළු බයිට් ගණනින් බෙදා ප්‍රගතිය ගණනය කරයි
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      }
    });

    final snap = await task;
    return await snap.ref.getDownloadURL();
  }
}
