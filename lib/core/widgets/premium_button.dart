import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Color? color;
  final double? height;
  final Gradient? gradient;

  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isOutlined = false,
    this.color,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Text(label),
      ],
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? (color ?? Theme.of(context).colorScheme.primary) : null,
            borderRadius: BorderRadius.circular(8),
            border: isOutlined ? Border.all(color: color ?? Theme.of(context).colorScheme.primary) : null,
          ),
          child: Center(child: child),
        ),
      ),
    );

    return button;
  }
}
