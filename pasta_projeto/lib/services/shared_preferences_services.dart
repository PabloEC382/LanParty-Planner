import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_keys.dart';

class SharedPreferencesService {
  Future<bool> getOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferencesKeys.onboardingDone) ?? false;
  }

  Future<void> setOnboardingDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesKeys.onboardingDone, value);
  }

  Future<bool> getConsentAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferencesKeys.consentAccepted) ?? false;
  }

  Future<void> setConsentAccepted(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesKeys.consentAccepted, v);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  static Future<String?> getUserPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_photo_path');
  }

  static Future<void> setUserPhotoPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove('user_photo_path');
    } else {
      await prefs.setString('user_photo_path', path);
    }
  }

  static Future<bool> getPrivacyPolicyAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('privacy_policy_all_read') ?? false;
  }

  static Future<void> setPrivacyPolicyAllRead(bool read) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_policy_all_read', read);
  }
}