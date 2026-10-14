import 'package:shared_preferences/shared_preferences.dart';

// Increment only when users need to acknowledge revised legal documents.
const int currentLegalVersion = 1;

class LegalAgreementService {
  LegalAgreementService(this.preferences);
  final SharedPreferences preferences;
  static const acceptedVersionKey = 'accepted_legal_version';

  bool get hasAcceptedCurrentVersion =>
      (preferences.getInt(acceptedVersionKey) ?? 0) >= currentLegalVersion;

  Future<void> acceptCurrentVersion() async {
    final saved = await preferences.setInt(
      acceptedVersionKey,
      currentLegalVersion,
    );
    if (!saved) throw StateError('Could not save legal agreement acceptance.');
  }

  Future<void> resetForDevelopment() async {
    final removed = await preferences.remove(acceptedVersionKey);
    if (!removed) {
      throw StateError('Could not reset legal agreement acceptance.');
    }
  }
}
