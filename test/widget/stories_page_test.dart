import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saha/core/models/enums.dart';
import 'package:saha/core/models/story.dart';
import 'package:saha/core/models/user.dart';
import 'package:saha/core/services/providers.dart';
import 'package:saha/features/stories/presentation/stories_page.dart';

void main() {
  testWidgets('displays stories from provider', (tester) async {
    final story = Story(
      id: 's1',
      userId: 'u1',
      isPro: true,
      mediaUrl: 'placeholder:story',
      caption: 'قصة اختبارية',
      createdAt: DateTime.now(),
      likes: 10,
      reactions: const [],
      hidden: false,
    );
    final user = User(
      id: 'u1',
      name: 'ليان',
      level: Level.beginner,
      preferences: const ['walk'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storiesProvider.overrideWith((ref) => Stream.value([story])),
          currentUserProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const MaterialApp(home: StoriesPage()),
      ),
    );

    await tester.pump();
    expect(find.text('قصة اختبارية'), findsOneWidget);
  });
}
