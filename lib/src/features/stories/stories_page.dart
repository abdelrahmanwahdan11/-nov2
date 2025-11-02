import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/state/app_scope.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stories = state.stories;

    return Scaffold(
      appBar: AppBar(title: const Text('القصص')),
      body: stories.isEmpty
          ? const Center(child: Text('لا توجد قصص'))
          : PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                final isPro = story.isPro;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 6),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => state.addStoryLike(story.id),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: isPro ? Colors.amber : Colors.white,
                                        child: Text(story.userId.substring(0, 2).toUpperCase()),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(story.caption, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text('${story.likes} ♥', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                                  const SizedBox(height: 12),
                                  Text('اضغط للإعجاب', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 320.ms).scale(begin: 0.96, end: 1),
                );
              },
            ),
    );
  }
}
