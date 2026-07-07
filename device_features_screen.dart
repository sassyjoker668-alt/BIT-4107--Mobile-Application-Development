import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'biometric_helper.dart';
import 'location_helper.dart';
import 'camera_helper.dart';
import 'offline_helper.dart';

class DeviceFeaturesScreen extends StatefulWidget {
  const DeviceFeaturesScreen({super.key});

  @override
  State<DeviceFeaturesScreen> createState() =>
      _DeviceFeaturesScreenState();
}

class _DeviceFeaturesScreenState
    extends State<DeviceFeaturesScreen> {
  bool _isOnline = false;
  bool _biometricAvailable = false;
  List<String> _biometricTypes = [];
  String _locationString = 'Not fetched yet';
  File? _capturedImage;
  bool _isLoadingLocation = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _checkAllFeatures();
  }

  Future<void> _checkAllFeatures() async {
    try {
      final connectivityResult =
      await Connectivity().checkConnectivity();
      final online = connectivityResult
          .contains(ConnectivityResult.mobile) ||
          connectivityResult
              .contains(ConnectivityResult.wifi);

      final biometric =
      await BiometricHelper.isBiometricAvailable();
      final types =
      await BiometricHelper.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _isOnline = online;
          _biometricAvailable = biometric;
          _biometricTypes = types
              .map((t) => t.name.toUpperCase())
              .toList();
        });
      }
    } catch (e) {
      print('Feature check error: $e');
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    final location =
    await LocationHelper.getLocationString();
    if (mounted) {
      setState(() {
        _locationString = location;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final image = await CameraHelper.takePhoto();
    if (image != null && mounted) {
      setState(() => _capturedImage = image);
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await CameraHelper.pickFromGallery();
    if (image != null && mounted) {
      setState(() => _capturedImage = image);
    }
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    await OfflineHelper.syncToFirebase();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data synced to Firebase!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testBiometric() async {
    try {
      final available =
      await BiometricHelper.isBiometricAvailable();

      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ No biometric found. Set up fingerprint in phone Settings first.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      final result = await BiometricHelper.authenticate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? '✅ Biometric authenticated!'
                  : '❌ Authentication failed or cancelled',
            ),
            backgroundColor:
            result ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Features'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAllFeatures,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Connectivity
            _SectionTitle(
              title: '1. Network Connectivity',
              icon: Icons.wifi,
            ),
            _FeatureCard(
              title: 'Internet Status',
              value: _isOnline
                  ? 'ONLINE ✅'
                  : 'OFFLINE ❌',
              color:
              _isOnline ? Colors.green : Colors.red,
              icon: _isOnline
                  ? Icons.wifi
                  : Icons.wifi_off,
            ),
            if (_isOnline)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                  _isSyncing ? null : _syncData,
                  icon: _isSyncing
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.sync),
                  label: Text(_isSyncing
                      ? 'Syncing...'
                      : 'Sync Offline Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // 2. GPS
            _SectionTitle(
              title: '2. GPS Location',
              icon: Icons.location_on,
            ),
            _FeatureCard(
              title: 'Current Location',
              value: _locationString,
              color: Colors.blue,
              icon: Icons.gps_fixed,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingLocation
                    ? null
                    : _getLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.my_location),
                label: Text(_isLoadingLocation
                    ? 'Getting location...'
                    : 'Get My Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Camera
            _SectionTitle(
              title: '3. Camera Access',
              icon: Icons.camera_alt,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(
                        Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_capturedImage != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _capturedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '✅ Image captured from device camera',
                style: TextStyle(color: Colors.green),
              ),
            ],
            const SizedBox(height: 20),

            // 4. Biometric
            _SectionTitle(
              title:
              '4. Biometric / Fingerprint / Face ID',
              icon: Icons.fingerprint,
            ),
            _FeatureCard(
              title: 'Biometric Available',
              value: _biometricAvailable
                  ? 'YES ✅'
                  : 'NOT AVAILABLE ❌',
              color: _biometricAvailable
                  ? Colors.green
                  : Colors.red,
              icon: Icons.fingerprint,
            ),
            if (_biometricTypes.isNotEmpty)
              _FeatureCard(
                title: 'Available Types',
                value: _biometricTypes.join(', '),
                color: Colors.teal,
                icon: Icons.security,
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text(
                    'Test Biometric Authentication'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. Offline Mode
            _SectionTitle(
              title: '5. Offline Mode',
              icon: Icons.offline_bolt,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _OfflineRow(
                    label:
                    'SQLite stores data locally offline',
                  ),
                  SizedBox(height: 8),
                  _OfflineRow(
                    label:
                    'Add income/expenses without internet',
                  ),
                  SizedBox(height: 8),
                  _OfflineRow(
                    label:
                    'Auto-syncs to Firebase when online',
                  ),
                  SizedBox(height: 8),
                  _OfflineRow(
                    label:
                    'Biometric login works offline too',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OfflineRow extends StatelessWidget {
  final String label;
  const _OfflineRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle,
            color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}