import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'product_card.dart';

/// Static placeholder grid shown while the catalog loads (no animation controllers).
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      sliver: SliverGrid(
        gridDelegate: kProductGridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, __) => const _SkeletonCard(),
          childCount: 6,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pastelOutline,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 76,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadii.slab),
          ),
        ),
      ),
    );
  }
}
