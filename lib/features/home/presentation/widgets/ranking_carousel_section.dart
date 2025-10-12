import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/home/presentation/widgets/story_card.dart';

class RankingCarouselSection extends StatelessWidget {
  final List<Story> stories;
  const RankingCarouselSection({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              "Bảng Xếp Hạng Tuần",
              style: theme.textTheme.headlineLarge,
            ),
          ),
          CarouselSlider.builder(
            itemCount: stories.length,
            itemBuilder: (context, index, realIndex) {
              final story = stories[index];
              return RankingStoryCard(story: story, rank: index + 1);
            },
            options: CarouselOptions(
              height: 300,
              // Tăng viewportFraction để card lớn hơn
              viewportFraction: 0.7, 
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
            ),
          ),
        ],
      ),
    );
  }
}

