import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Featured promotional capsule on the Home screen.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryInk,
        borderRadius: BorderRadius.circular(AppRadii.banner),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -28,
            top: -28,
            child: _Disc(size: 130, color: AppColors.whiteGlass),
          ),
          const Positioned(
            right: 36,
            bottom: -34,
            child: _Disc(size: 90, color: AppColors.pastelOutline),
          ),
          const Positioned(
            right: 20,
            top: 0,
            bottom: 10,
            child: Icon(
              Icons.local_offer_rounded,
              size: 54,
              color: AppColors.pastelPedestal,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 110, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteGlass,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'PROMO MINGGU INI',
                    style: AppText.labelMedium.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  'Diskon hingga 30%',
                  style: AppText.headlineMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  'Gratis ongkir untuk pesanan pertama',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.labelMedium.copyWith(
                    color: AppColors.pastelPedestal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
