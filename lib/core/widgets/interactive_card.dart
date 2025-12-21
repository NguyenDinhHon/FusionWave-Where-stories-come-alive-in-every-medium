import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Interactive card với các hiệu ứng chuyên nghiệp:
/// - Hover effects
/// - Scale animations
/// - Shadow effects
/// - Ripple effects
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double elevation;
  final Gradient? gradient;
  final Border? border;
  final bool enableHover;
  final bool enableScale;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.elevation = 2,
    this.gradient,
    this.border,
    this.enableHover = true,
    this.enableScale = true,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation * 1.5,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    Widget card = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableScale ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: widget.margin,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.gradient == null
                  ? (widget.backgroundColor ?? Colors.white)
                  : null,
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    _isHovered ? 0.15 : 0.1,
                  ),
                  blurRadius: _elevationAnimation.value,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: AppColors.primary.withOpacity(0.1),
                highlightColor: AppColors.primary.withOpacity(0.05),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );

    if (widget.enableHover && isEnabled) {
      card = MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        cursor: SystemMouseCursors.click,
        child: card,
      );
    }

    return card;
  }
}

