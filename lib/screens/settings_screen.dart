import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/in_app_webview_page.dart';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final InAppReview _inAppReview = InAppReview.instance;
  bool _isBiometricEnabled = StorageService.instance.isBiometricEnabled;
  final String _appVersion = "1.0.12"; // Matching pubspec.yaml

  // Professional sharing message
  final String _shareText =
      "Check out Finbos - Finance with AI! Manage your transactions and get AI insights effortlessly. Download now: https://finbos.app";

  void _openInternalUrl(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InAppWebViewPage(url: url, title: title),
      ),
    );
  }

  Future<void> _handleRateApp() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        // Fallback or ignore
        debugPrint('In-app review not available');
      }
    } catch (e) {
      debugPrint('Error triggering review: $e');
    }
  }

  void _handleShareApp() {
    Share.share(_shareText);
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      // If turning ON, authenticate first to verify the user has biometrics set up
      final bool authenticated = await BiometricService.instance.authenticate();
      if (authenticated) {
        setState(() {
          _isBiometricEnabled = true;
        });
        await StorageService.instance.setBiometricEnabled(true);
      } else {
        // Did not authenticate, keep it off
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not verify biometrics. Lock not enabled.'),
            ),
          );
        }
      }
    } else {
      // If turning OFF, just do it
      setState(() {
        _isBiometricEnabled = false;
      });
      await StorageService.instance.setBiometricEnabled(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Match WebViewScreen background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 10),
              _buildSectionHeader('Security'),
              _buildSettingTile(
                icon: LineIcons.fingerprint,
                title: 'Biometric Lock',
                subtitle: 'Secure your data with FaceID/TouchID',
                trailing: Switch(
                  value: _isBiometricEnabled,
                  onChanged: _toggleBiometrics,
                  activeColor: const Color(0xFF00C7F4),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Community & Support'),
              _buildSettingTile(
                icon: LineIcons.star,
                title: 'Rate the App',
                subtitle: 'Let us know how we are doing',
                onTap: _handleRateApp,
              ),
              _buildSettingTile(
                icon: LineIcons.share,
                title: 'Share Finbos',
                subtitle: 'Invite your friends to manage finance with AI',
                onTap: _handleShareApp,
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('App Info'),
              _buildSettingTile(
                icon: LineIcons.infoCircle,
                title: 'Version',
                subtitle: _appVersion,
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
              _buildSettingTile(
                icon: LineIcons.fileContract,
                title: 'Terms & Privacy',
                subtitle: 'Read our policies',
                onTap: () => _openInternalUrl(
                  'https://finbos.app/PrivacyPolicy',
                  'Privacy Policy',
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00C7F4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00C7F4), size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
      ],
    );
  }
}
