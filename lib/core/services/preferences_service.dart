import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyGuestMode = 'guest_mode';
  static const String _keyGuestUserId = 'guest_user_id';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
  }

  bool get isGuestMode => _prefs.getBool(_keyGuestMode) ?? false;
  
  Future<void> setGuestMode(bool value) async {
    await _prefs.setBool(_keyGuestMode, value);
  }

  String? get guestUserId => _prefs.getString(_keyGuestUserId);
  
  Future<void> setGuestUserId(String userId) async {
    await _prefs.setString(_keyGuestUserId, userId);
  }

  Future<void> clearGuestData() async {
    await _prefs.remove(_keyGuestMode);
    await _prefs.remove(_keyGuestUserId);
  }
}
