import 'package:flutter/material.dart';

import '../../../core/constants/app_gradients.dart';
import '../../../core/localization/app_localizations.dart';

class StoryViewerScreen extends StatelessWidget {
  const StoryViewerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
              fit: BoxFit.cover,
              semanticLabel: l10n.t('mock_story'),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.imageOverlay),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1552196563-55cd4e45efb3'),
                      ),
                      const SizedBox(width: 12),
                      Text('Pro Athlete', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: l10n.t('close'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: l10n.t('comment') ?? '...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.12),
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
                        tooltip: l10n.t('like'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
