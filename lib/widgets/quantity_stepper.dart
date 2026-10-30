import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Controlled stepper. [max] already accounts for the per-order limit and stock.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.max,
    required this.perOrderLimit,
    required this.onChanged,
  });

  final int value;
  final int max;
  final int perOrderLimit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final limitedByStock = max < perOrderLimit;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadii.control),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah', style: AppText.titleMedium),
                Text(
                  limitedByStock
                      ? 'Stok tersisa $max'
                      : 'Maks. $perOrderLimit per pesanan',
                  style: AppText.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Kurangi',
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.canvasBackground,
                  foregroundColor: AppColors.primaryInk,
                  disabledBackgroundColor: AppColors.canvasBackground,
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppText.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Tambah',
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryInk,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.pastelOutline,
                  disabledForegroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
