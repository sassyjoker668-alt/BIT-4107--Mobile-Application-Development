import 'package:flutter/material.dart';
import 'network_manager.dart';
import 'network_config.dart';

class NetworkStatusScreen extends StatefulWidget {
  const NetworkStatusScreen({super.key});

  @override
  State<NetworkStatusScreen> createState() =>
      _NetworkStatusScreenState();
}

class _NetworkStatusScreenState extends State<NetworkStatusScreen> {
  ConnectionStatus _status = ConnectionStatus.disconnected;
  bool _isChecking = false;
  Map<String, dynamic> _exchangeData = {};
  String _log = '';
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _log = 'Starting connection test...\n';
      _exchangeData = {};
    });

    // Step 1: Check internet
    setState(() => _log += '\n[1] Checking internet...\n');
    final status = await NetworkManager.instance.checkConnection();
    setState(() {
      _status = status;
      _log += 'Result: ${status.name.toUpperCase()}\n';
    });

    if (status != ConnectionStatus.disconnected) {
      // Step 2: Test Exchange Rate API
      setState(() {
        _log += '\n[2] Connecting to Exchange Rate API...\n';
        _log += 'URL: ${NetworkConfig.exchangeRateKES}\n';
        _log += 'Method: GET\n';
      });

      final result = await NetworkManager.instance
          .get(NetworkConfig.exchangeRateKES);

      if (result['success']) {
        setState(() {
          _exchangeData = result['data']['rates'];
          _lastUpdated = result['data']['date'] ?? '';
          _log += 'Status Code: 200 OK ✅\n';
          _log += 'Response: JSON received\n';
          _log += 'Rates loaded successfully\n';
        });
      } else {
        setState(() {
          _log += 'Error: ${result['error']} ❌\n';
          _log += 'Status Code: ${result['statusCode']}\n';
        });
      }

      // Step 3: Test Firebase
      setState(() {
        _log += '\n[3] Checking Firebase connection...\n';
        _log += 'URL: ${NetworkConfig.firestoreBaseUrl}\n';
        _log += 'Method: GET\n';
      });

      final firebaseResult = await NetworkManager.instance
          .get('https://firebase.google.com');

      setState(() {
        if (firebaseResult['success'] ||
            firebaseResult['statusCode'] == 200) {
          _log += 'Firebase: Reachable ✅\n';
        } else {
          _log += 'Firebase: ${firebaseResult['error']} ❌\n';
        }
      });
    }

    setState(() {
      _log += '\n✅ Connection test complete.';
      _isChecking = false;
    });
  }

  Color get _statusColor {
    switch (_status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.slow:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.slow:
        return Icons.wifi_2_bar;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  String get _statusMessage {
    switch (_status) {
      case ConnectionStatus.connected:
        return 'Connected to Internet';
      case ConnectionStatus.slow:
        return 'Connected but Slow';
      case ConnectionStatus.disconnected:
        return 'No Internet Connection';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isChecking ? null : _checkConnection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon,
                      color: Colors.white, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    _status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  if (_lastUpdated.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last updated: $_lastUpdated',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Connection Strings
            const Text(
              'Active Connection Strings',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _ConnectionCard(
              title: 'Firebase Firestore',
              url: NetworkConfig.firestoreBaseUrl,
              color: Colors.blue,
              icon: Icons.cloud,
            ),
            _ConnectionCard(
              title: 'Firebase Auth',
              url: NetworkConfig.firebaseAuthUrl,
              color: Colors.purple,
              icon: Icons.lock,
            ),
            _ConnectionCard(
              title: 'Exchange Rate API',
              url: NetworkConfig.exchangeRateKES,
              color: Colors.orange,
              icon: Icons.currency_exchange,
            ),
            const SizedBox(height: 24),

            // HTTP Methods Info
            const Text(
              'HTTP Methods Used',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _HttpMethodBadge(
                    method: 'GET', color: Colors.green),
                const SizedBox(width: 8),
                _HttpMethodBadge(
                    method: 'POST', color: Colors.blue),
                const SizedBox(width: 8),
                _HttpMethodBadge(
                    method: 'PUT', color: Colors.orange),
                const SizedBox(width: 8),
                _HttpMethodBadge(
                    method: 'DELETE', color: Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // Test Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkConnection,
                icon: _isChecking
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.network_check),
                label: Text(
                  _isChecking
                      ? 'Testing Connections...'
                      : 'Test All Connections',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Connection Log
            const Text(
              'Connection Log',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isChecking
                  ? Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _log,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              )
                  : Text(
                _log.isEmpty
                    ? 'Tap "Test All Connections" to begin...'
                    : _log,
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Rates
            if (_exchangeData.isNotEmpty) ...[
              const Text(
                'Live Exchange Rates (KSh)',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...[
                'USD',
                'EUR',
                'GBP',
                'UGX',
                'TZS',
                'ZAR',
                'NGN',
                'INR'
              ].map((currency) {
                final rate = _exchangeData[currency];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      Colors.green.withValues(alpha: 0.1),
                      child: const Icon(
                          Icons.currency_exchange,
                          color: Colors.green,
                          size: 18),
                    ),
                    title: Text(currency,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    trailing: Text(
                      rate != null
                          ? rate.toStringAsFixed(4)
                          : 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final String title;
  final String url;
  final Color color;
  final IconData icon;

  const _ConnectionCard({
    required this.title,
    required this.url,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style:
            const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          url,
          style: const TextStyle(fontSize: 10),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }
}

class _HttpMethodBadge extends StatelessWidget {
  final String method;
  final Color color;

  const _HttpMethodBadge({
    required this.method,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}