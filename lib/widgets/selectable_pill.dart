import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class SelectablePill extends StatelessWidget {
  const SelectablePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryInk : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? AppColors.primaryInk : AppColors.pastelOutline,
            ),
            boxShadow: selected ? AppShadows.soft : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(
                label,
                style: AppText.labelMedium.copyWith(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.primaryInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
