import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(
                  AssetsManager.appLogo,
                )
                //Lottie.asset(AssetsManager.clipboardAnimation),
                ),
            const SizedBox(height: 20),
            Text(
              'AI Risk Assessment App',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Version $appVersion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Empowering Safety Through AI',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
                'About Us',
                'AI Risk Assessment App is developed by [Your Company Name], '
                    'a leader in innovative safety solutions. Our mission is to '
                    'revolutionize workplace safety through cutting-edge AI technology.'),
            _buildInfoSection(
                'Key Features',
                '• AI-powered Daily Safety Task Instructions (DSTI)\n'
                    '• Intelligent Risk Assessments\n'
                    '• Comprehensive Tools Management\n'
                    '• Collaborative Organization Features'),
            _buildInfoSection(
                'Our Commitment',
                'We are committed to enhancing workplace safety by providing '
                    'state-of-the-art tools that leverage artificial intelligence. '
                    'Our goal is to make safety management more efficient, accurate, '
                    'and accessible for businesses of all sizes.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement navigation to your website or contact page
              },
              child: const Text('Visit Our Website'),
            ),
            const SizedBox(height: 20),
            Text(
              '© ${DateTime.now().year} [Your Company Name]. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
