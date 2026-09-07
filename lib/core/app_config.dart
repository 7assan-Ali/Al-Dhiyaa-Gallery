import 'package:flutter/foundation.dart';

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get cloudEnabled =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static const shopName = 'الضياء';
  static const currency = 'ج.م';
  static const creditMarkup = 0.30;

  static String get platformName {
    if (kIsWeb) return 'Web';
    return defaultTargetPlatform.name;
  }
}
