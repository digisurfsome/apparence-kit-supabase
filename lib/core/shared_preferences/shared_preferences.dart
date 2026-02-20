import 'package:apparence_kit/core/initializer/onstart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesBuilder>(
  (ref) => SharedPreferencesBuilder(),
);

class SharedPreferencesBuilder implements OnStartService {
  SharedPreferences? _sharedPreferences;

  @override
  Future<void> init() async {
    if (_sharedPreferences != null) {
      return;
    }
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_sharedPreferences == null) {
      throw Exception('SharedPreferences not loaded');
    }
    return _sharedPreferences!;
  }

  /// Save the latest seen update version
  Future<void> setLastSeenUpdateVersion(String version) async {
    await prefs.setString('last_seen_update_version', version);
  }

  /// Get the latest seen update version
  String? getLastSeenUpdateVersion() {
    return prefs.getString('last_seen_update_version');
  }
}
