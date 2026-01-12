import 'package:flutter/material.dart';

/// App button với gradient và animations
class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Gradient? gradient;
  final bool isOutlined;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? textColor;
  final Color? iconColor;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.gradient,
    this.isOutlined = false,
    this.width,
    this.height,
    this.padding,
    this.textColor,
    this.iconColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: widget.width,
      height: widget.height ?? 48,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient:
            widget.gradient ??
            (widget.color != null
                ? LinearGradient(
                    colors: [widget.color!, widget.color!.withOpacity(0.8)],
                  )
                : null),
        color: widget.gradient == null && widget.color != null
            ? widget.color
            : null,
        borderRadius: BorderRadius.circular(12),
        border: widget.isOutlined
            ? Border.all(
                color: widget.color ?? Theme.of(context).primaryColor,
                width: 2,
              )
            : null,
        boxShadow: widget.isOutlined
            ? null
            : [
                BoxShadow(
                  color: (widget.color ?? Theme.of(context).primaryColor)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed != null
              ? () {
                  _controller.forward().then((_) {
                    _controller.reverse();
                  });
                  widget.onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color:
                        widget.iconColor ??
                        (widget.isOutlined
                            ? (widget.color ?? Theme.of(context).primaryColor)
                            : Colors.white),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color:
                        widget.textColor ??
                        (widget.isOutlined
                            ? (widget.color ?? Theme.of(context).primaryColor)
                            : Colors.white),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return ScaleTransition(scale: _scaleAnimation, child: button);
  }
}
