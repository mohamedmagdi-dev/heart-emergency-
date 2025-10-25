import 'shared_preferences_helper.dart';

class OnboardingHelper {
  static const String _onboardingKey = 'has_completed_onboarding';

  /// Check if the user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    return await SharedPreferencesHelper.getBool(_onboardingKey);
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    await SharedPreferencesHelper.setBool(_onboardingKey, true);
  }

  /// Reset onboarding status (useful for testing)
  static Future<void> resetOnboarding() async {
    await SharedPreferencesHelper.setBool(_onboardingKey, false);
  }

  /// Clear all app data (useful for testing)
  static Future<void> clearAllData() async {
    await SharedPreferencesHelper.clear();
  }
}
