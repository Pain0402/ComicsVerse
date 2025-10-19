import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/home/presentation/widgets/story_card.dart';

class ForYouGridSection extends StatelessWidget {
  final List<Story> stories;

  const ForYouGridSection({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "For You",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
          ),
          if (stories.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text("No stories found.")),
            )
          else
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2 / 3.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return StoryCard(story: stories[index]).animate().fadeIn(
                        delay: (index * 70).ms,
                        duration: 400.ms,
                      ).slideY(begin: 0.2);
                },
                childCount: stories.length,
              ),
            ),
        ],
      ),
    );
  }
}
