import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class StoryViewerScreen extends StatelessWidget {
  const StoryViewerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              children: [
                const CircleAvatar(backgroundImage: NetworkImage('https://images.unsplash.com/photo-1552196563-55cd4e45efb3')),
                const SizedBox(width: 12),
                Text('Pro Athlete', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.t('comment') ?? '...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
