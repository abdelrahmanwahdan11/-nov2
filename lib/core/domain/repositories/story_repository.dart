import '../../models/story.dart';

abstract class StoryRepository {
  Stream<List<Story>> watchStories();
  Future<void> addStory(Story story);
  Future<void> toggleReaction(String storyId, String userId);
  Future<void> reportStory(String storyId);
}
