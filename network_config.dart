class NetworkConfig {
  // ─── Firebase Config ──────────────────────────
  static const String firebaseProjectId = 'YOUR-PROJECT-ID';
  static const String firebaseApiKey = 'YOUR-API-KEY';

  static const String firestoreBaseUrl =
      'https://firestore.googleapis.com/v1/projects/'
      '$firebaseProjectId/databases/(default)/documents';

  static const String firebaseAuthUrl =
      'https://identitytoolkit.googleapis.com/v1/'
      'accounts:signInWithPassword?key=$firebaseApiKey';

  // ─── Exchange Rate API ────────────────────────
  static const String exchangeRateBaseUrl =
      'https://api.exchangerate-api.com/v4/latest';

  static const String exchangeRateKES =
      '$exchangeRateBaseUrl/KES';

  // ─── Timeouts ─────────────────────────────────
  static const Duration connectionTimeout =
  Duration(seconds: 30);
  static const Duration receiveTimeout =
  Duration(seconds: 30);

  // ─── HTTP Headers ─────────────────────────────
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}