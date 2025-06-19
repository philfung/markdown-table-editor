import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: footerBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              const url = 'https://github.com/philfung/markdown-table-editor';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              'GitHub',
              style: TextStyle(color: footerTextColor),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () async {
              const url = 'https://flutter.dev';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              'Written in Flutter',
              style: TextStyle(color: footerTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
