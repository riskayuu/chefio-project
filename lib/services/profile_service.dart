import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  Future<void> createOrUpdateProfile({
    required String userId,
    required String fullName,
    required String email,
    String? username,
    String? gender,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'username': username,
        'gender': gender,
        'phone_number': phoneNumber,
        'profile_image_url': profileImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _supabase.storage
          .from('profiles')
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _supabase
          .from('profiles')
          .update({'profile_image_url': imageUrl})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.skip(pathSegments.indexOf('profiles') + 1).join('/');
      
      await _supabase.storage
          .from('profiles')
          .remove([fileName]);
    } catch (e) {
      print('Error deleting old profile image: $e');
    }
  }
}