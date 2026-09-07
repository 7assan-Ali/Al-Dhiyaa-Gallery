import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';

class CloudService {
  static Future<void> initialize() async {
    if (!AppConfig.cloudEnabled) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  static SupabaseClient? get client {
    if (!AppConfig.cloudEnabled) return null;
    return Supabase.instance.client;
  }

  static Future<void> signOut() async {
    final supabase = client;
    if (supabase != null) await supabase.auth.signOut();
  }
}
