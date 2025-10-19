import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';
import 'package:comicsapp/features/profile/presentation/providers/profile_providers.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer(
      builder: (context, ref, child) {
        final userProfileAsync = ref.watch(userProfileProvider);

        return SliverAppBar(
          pinned: true,
          expandedHeight: 180.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
            background: _buildExpandedBackground(context, userProfileAsync),
          ),
          actions: [
            IconButton(
              onPressed: () => context.push('/search'),
              icon: Icon(Icons.search_rounded, size: 28, color: theme.colorScheme.onBackground),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  /// Builds the content of the expanded app bar, handling loading and error states.
  Widget _buildExpandedBackground(BuildContext context, AsyncValue<Profile?> userProfileAsync) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: userProfileAsync.when(
          data: (profile) => [
            Text(
              "Good morning,",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              profile?.displayName ?? 'Guest',
              style: theme.textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          loading: () => [
            Shimmer.fromColors(
              baseColor: Colors.grey.withOpacity(0.3),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 30, width: 200, color: Colors.white),
                ],
              ),
            ),
          ],
          error: (e, s) => [
            Text(
              "HI,",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              'ComicsApp',
              style: theme.textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
