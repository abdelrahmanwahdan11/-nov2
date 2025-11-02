import 'dart:async';
import 'package:collection/collection.dart';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/story_repository.dart';
import '../../../core/models/story.dart';

class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Stream<List<Story>> watchStories() {
    final box = _manager.box<Story>(HiveBoxes.stories);
    final controller = StreamController<List<Story>>.broadcast();

    void emit() {
      final stories = box.values
          .where((story) => !story.hidden)
          .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
          .toList();
      controller.add(stories);
    }

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<void> addStory(Story story) async {
    await _manager.box<Story>(HiveBoxes.stories).put(story.id, story);
  }

  @override
  Future<void> toggleReaction(String storyId, String userId) async {
    final box = _manager.box<Story>(HiveBoxes.stories);
    final story = box.get(storyId);
    if (story == null) {
      return;
    }
    final reactions = [...story.reactions];
    if (reactions.contains(userId)) {
      reactions.remove(userId);
    } else {
      reactions.add(userId);
    }
    final updated = story.copyWith(
      reactions: reactions,
      likes: reactions.length,
    );
    await box.put(storyId, updated);
  }

  @override
  Future<void> reportStory(String storyId) async {
    final box = _manager.box<Story>(HiveBoxes.stories);
    final story = box.get(storyId);
    if (story == null) {
      return;
    }
    await box.put(storyId, story.copyWith(hidden: true));
  }
}
