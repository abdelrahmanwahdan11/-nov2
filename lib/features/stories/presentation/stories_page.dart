import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/story.dart';
import '../../../core/services/providers.dart';
import 'story_controller.dart';

class StoriesPage extends ConsumerStatefulWidget {
  const StoriesPage({super.key});

  @override
  ConsumerState<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends ConsumerState<StoriesPage> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoplay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final stories = ref.read(storiesProvider).value ?? [];
      if (stories.isEmpty) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % stories.length;
        _controller.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم', style: TextStyle(color: Colors.white))); 
          }
          return storiesAsync.when(
            data: (stories) {
              if (stories.isEmpty) {
                return const Center(child: Text('لا توجد قصص حالياً', style: TextStyle(color: Colors.white)));
              }
              return PageView.builder(
                controller: _controller,
                itemCount: stories.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final story = stories[index];
                  final liked = story.reactions.contains(user.id);
                  return _StoryView(
                    story: story,
                    liked: liked,
                    onLike: () => _toggleReaction(story.id, user.id),
                    onReport: () => _reportStory(story.id),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('خطأ: $error', style: const TextStyle(color: Colors.white))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Future<void> _toggleReaction(String storyId, String userId) async {
    await ref.read(storyControllerProvider.notifier).toggleReaction(storyId, userId);
  }

  Future<void> _reportStory(String storyId) async {
    await ref.read(storyControllerProvider.notifier).report(storyId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الإبلاغ عن القصة')));
    }
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({
    required this.story,
    required this.liked,
    required this.onLike,
    required this.onReport,
  });

  final Story story;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _StoryBackground(
            story: story,
          ),
        ),
        Positioned(
          top: 60,
          left: 24,
          right: 24,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(story.isPro ? 'PRO' : 'USER'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(story.caption, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                      '${story.likes} إعجاب',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onReport,
                icon: const Icon(Icons.flag, color: Colors.white70),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'أرسل تفاعل...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black45,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryBackground extends StatelessWidget {
  const _StoryBackground({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final usePlaceholder = story.mediaUrl.isEmpty || story.mediaUrl.startsWith('placeholder:');
    if (usePlaceholder) {
      return _GradientPlaceholder(
        seed: story.id,
        label: story.mediaUrl.contains(':') ? story.mediaUrl.split(':').last : null,
      );
    }
    return Image.asset(
      story.mediaUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _GradientPlaceholder(
        seed: story.id,
        label: story.mediaUrl,
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.seed, this.label});

  final String seed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFromSeed(seed);
    final displayLabel = (label ?? '').trim();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          displayLabel.isEmpty ? 'Story' : displayLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Color> _colorsFromSeed(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0xFFFFFF;
    }
    final hue1 = (hash % 360).toDouble();
    final hue2 = ((hash >> 5) % 360).toDouble();
    final color1 = HSLColor.fromAHSL(1, hue1, 0.55, 0.45).toColor();
    final color2 = HSLColor.fromAHSL(1, hue2, 0.6, 0.6).toColor();
    return [color1, color2];
  }
}
