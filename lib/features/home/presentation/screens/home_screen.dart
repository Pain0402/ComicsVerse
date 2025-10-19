import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:comicsapp/core/config/theme/app_theme.dart';
import 'package:comicsapp/features/home/presentation/providers/home_providers.dart';
import 'package:comicsapp/features/home/presentation/widgets/for_you_grid_section.dart';
import 'package:comicsapp/features/home/presentation/widgets/home_sliver_app_bar.dart';
import 'package:comicsapp/features/home/presentation/widgets/ranking_carousel_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsyncValue = ref.watch(allStoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.brightness == Brightness.dark ? AppTheme.primaryBackground : AppTheme.primaryBackgroundLight,
              theme.brightness == Brightness.dark ? const Color(0xFF1A234E) : const Color(0xFFE0E4FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: storiesAsyncValue.when(
          loading: () => _buildLoadingSkeleton(context),
          error: (error, stackTrace) => Center(
            child: Text('Error loading data: ${error.toString()}'),
          ),
          data: (stories) {
            return CustomScrollView(
              slivers: [
                const HomeSliverAppBar(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                RankingCarouselSection(stories: stories.take(5).toList()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ForYouGridSection(stories: stories),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(height: 20, width: 150, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 30, width: 250, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2 / 3.5,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
