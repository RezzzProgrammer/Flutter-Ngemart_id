import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.active = false,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryInk : AppColors.surfaceWhite,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Icon(
            icon,
            size: size * 0.45,
            color: active ? Colors.white : AppColors.primaryInk,
          ),
        ),
      ),
    );
  }
}
