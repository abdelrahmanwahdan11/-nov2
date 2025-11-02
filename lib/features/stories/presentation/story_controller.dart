import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/story_repository.dart';
import '../../../core/models/story.dart';
import '../../../core/services/providers.dart';

class StoryController extends StateNotifier<AsyncValue<void>> {
  StoryController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  StoryRepository get _repository => _ref.read(storyRepositoryProvider);

  Future<void> toggleReaction(String storyId, String userId) async {
    try {
      await _repository.toggleReaction(storyId, userId);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      state = const AsyncValue.data(null);
    }
  }

  Future<void> report(String storyId) async {
    try {
      await _repository.reportStory(storyId);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      state = const AsyncValue.data(null);
    }
  }

  Future<void> addStory(Story story) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addStory(story);
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final storyControllerProvider =
    StateNotifierProvider<StoryController, AsyncValue<void>>(
  (ref) => StoryController(ref),
);
