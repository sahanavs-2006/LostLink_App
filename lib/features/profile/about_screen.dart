import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About LostLink'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.link_rounded, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'LostLink',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Version 1.0.0 (Hackathon Build)',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const Text(
              'LostLink is a modern, smart, and efficient digital lost-and-found system designed for public transport networks. It bridges the gap between commuters who lose items and the finders/officers who recover them using real-time data and automated matching.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Visit Website'),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () {
                Helpers.showSnackBar(context, 'Website launching soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () {
                Helpers.showSnackBar(context, 'Terms document coming soon!');
              },
            ),
          ],
        ),
      ),
    );
  }
}
