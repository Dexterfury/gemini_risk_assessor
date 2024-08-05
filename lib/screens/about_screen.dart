import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appVersion = '';

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'About Screen',
      screenClass: 'AboutScreen',
    );
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
              ),
              // Lottie.asset(AssetsManager.clipboardAnimation), // If you have a Lottie animation
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
            _buildInfoSection('About the App',
                'This app utilizes the power of AI to help you identify and manage potential risks, promoting a safer environment. Whether you\'re at work, home, or on-the-go, this app provides the insights you need to stay safe.'),
            _buildInfoSection(
                'Key Features',
                '• Intelligent Risk Assessments\n'
                    '• Comprehensive Tools Management\n'
                    '• Collaborative Group Features with AI'),
            _buildInfoSection('Developed by Raphael Daka',
                'I am passionate about leveraging technology to solve real-world problems. I believe in the potential of AI to significantly improve safety measures and risk management.'),
            const SizedBox(height: 20),
            //Optional: Add social media links if you have
            ElevatedButton(
              onPressed: () =>
                  _launchURL('https://www.youtube.com/@dexterfury538'),
              child: const Text('Visit My Channel'),
            ),
            // const SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: () => _launchURL('https://twitter.com/yourusername'),
            //   child: const Text('Follow me on Twitter'),
            // ),
            const SizedBox(height: 20),
            Text(
              '© ${DateTime.now().year} Raphael Daka. All rights reserved.',
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

// Uncomment this section if you add social media links
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}

// class AboutScreen extends StatefulWidget {
//   const AboutScreen({super.key});

//   @override
//   State<AboutScreen> createState() => _AboutScreenState();
// }

// class _AboutScreenState extends State<AboutScreen> {
//   String appVersion = '';

//   @override
//   void initState() {
//     super.initState();
//     _getAppVersion();
//   }

//   Future<void> _getAppVersion() async {
//     final packageInfo = await PackageInfo.fromPlatform();
//     setState(() {
//       appVersion = packageInfo.version;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('About'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             SizedBox(
//                 height: 150,
//                 width: 150,
//                 child: Image.asset(
//                   AssetsManager.appLogo,
//                 )
//                 //Lottie.asset(AssetsManager.clipboardAnimation),
//                 ),
//             const SizedBox(height: 20),
//             Text(
//               'AI Risk Assessment App',
//               style: Theme.of(context).textTheme.titleLarge,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Version $appVersion',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Empowering Safety Through AI',
//               style: Theme.of(context).textTheme.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             _buildInfoSection(
//                 'About Us',
//                 'AI Risk Assessment App is developed by Raphael Daka, '
//                     'a leader in innovative safety solutions. Our mission is to '
//                     'revolutionize workplace safety through cutting-edge AI technology.'),
//             _buildInfoSection(
//                 'Key Features',
//                 '• AI-powered Daily Safety Task Instructions (DSTI)\n'
//                     '• Intelligent Risk Assessments\n'
//                     '• Comprehensive Tools Management\n'
//                     '• Collaborative Group Features with AI'),
//             _buildInfoSection(
//                 'Our Commitment',
//                 'We are committed to enhancing workplace safety by providing '
//                     'state-of-the-art tools that leverage artificial intelligence. '
//                     'Our goal is to make safety management more efficient, accurate, '
//                     'and accessible for businesses of all sizes.'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement navigation to your website or contact page
//               },
//               child: const Text('Visit Our Website'),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               '© ${DateTime.now().year} [Your Company Name]. All rights reserved.',
//               style: Theme.of(context).textTheme.bodySmall,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoSection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             content,
//             style: const TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
