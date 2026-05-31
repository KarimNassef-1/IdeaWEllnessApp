import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/app_image.dart';
import '../../widgets/gradient_button.dart';

class PartnerDetailScreen extends StatelessWidget {
  const PartnerDetailScreen({
    super.key,
    required this.name,
    required this.image,
    this.url,
  });

  final String name;
  final String image;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AppImage(
                source: image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$name x Idea Wellness',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore exclusive collaborations, member discounts, and experiences '
              'designed to enhance your training lifestyle.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            if (url != null)
              GradientButton(
                label: 'Visit $name',
                icon: Icons.open_in_new_rounded,
                onPressed: () async {
                  final uri = Uri.tryParse(url!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
