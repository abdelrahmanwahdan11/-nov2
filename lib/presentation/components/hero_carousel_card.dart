import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeroCarouselCard extends StatelessWidget {
  const HeroCarouselCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.heroTag,
  });

  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = heroTag ?? 'catalog_$id';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: tag,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: Colors.black12);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.75)],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
