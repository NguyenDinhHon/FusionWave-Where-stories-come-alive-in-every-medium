import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';

/// Interactive button với các hiệu ứng chuyên nghiệp:
/// - Hover effects
/// - Ripple effects
/// - Scale animations
/// - Shadow effects
/// - Loading states
/// - Disabled states
/// - Focus states
class InteractiveButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Gradient? gradient;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;
  final bool isIconButton;
  final String? tooltip;
  final Duration animationDuration;

  const InteractiveButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.gradient,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12,
    this.elevation = 4,
    this.isIconButton = false,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : assert(label != null || icon != null, 'Either label or icon must be provided');

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    // When isOutlined is true, background should be transparent
    final effectiveBackgroundColor = widget.isOutlined
        ? (widget.backgroundColor ?? Colors.transparent)
        : (widget.gradient != null
            ? null
            : (widget.backgroundColor ?? (widget.isIconButton ? Colors.transparent : AppColors.primary)));
    final effectiveTextColor = widget.textColor ??
        (widget.isOutlined
            ? (widget.backgroundColor ?? AppColors.primary)
            : (widget.isIconButton 
                ? AppColors.iconLight
                : Colors.white));
    // For icon buttons without background, use explicit iconColor or default to iconLight
    final effectiveIconColor = widget.iconColor ?? 
        (widget.isIconButton && (effectiveBackgroundColor == Colors.transparent || effectiveBackgroundColor == null)
            ? AppColors.iconLight
            : effectiveTextColor);

    Widget button = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height ?? (widget.isIconButton ? 32 : 36),
            padding: widget.padding ??
                (widget.isIconButton
                    ? const EdgeInsets.all(6)
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            decoration: BoxDecoration(
              gradient: widget.gradient ??
                  (effectiveBackgroundColor != null && !widget.isOutlined
                      ? LinearGradient(
                          colors: [
                            effectiveBackgroundColor,
                            effectiveBackgroundColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null),
              color: widget.gradient == null && effectiveBackgroundColor != null && !widget.isOutlined
                  ? effectiveBackgroundColor
                  : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.isOutlined
                  ? Border.all(
                      color: effectiveBackgroundColor ?? AppColors.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: !widget.isOutlined && isEnabled
                  ? (_isHovered || _isPressed
                      ? AppShadows.shadowHover
                      : AppShadows.shadowSmall)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: null, // Don't use onTap, use onTapUp instead to avoid double calls
                onTapDown: isEnabled ? _handleTapDown : null,
                onTapUp: isEnabled ? _handleTapUp : null,
                onTapCancel: isEnabled ? _handleTapCancel : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: effectiveTextColor.withOpacity(0.2),
                highlightColor: effectiveTextColor.withOpacity(0.1),
                child: Container(
                  alignment: Alignment.center,
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              effectiveTextColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null && widget.label != null) ...[
                              Icon(
                                widget.icon,
                                color: effectiveIconColor,
                                size: widget.isIconButton ? 20 : 18,
                              ),
                              const SizedBox(width: 6),
                            ] else if (widget.icon != null && widget.label == null)
                              Icon(
                                widget.icon,
                                color: effectiveIconColor,
                                size: widget.isIconButton ? 20 : 18,
                              ),
                            if (widget.label != null)
                              Flexible(
                                child: Text(
                                  widget.label!,
                                  style: TextStyle(
                                    color: effectiveTextColor,
                                    fontSize: widget.isIconButton ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Wrap with MouseRegion for hover effects
    button = MouseRegion(
      onEnter: (_) {
        if (isEnabled) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: button,
    );

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    // Add opacity for disabled state
    if (!isEnabled) {
      button = Opacity(
        opacity: 0.6,
        child: button,
      );
    }

    return button;
  }
}

/// Interactive IconButton với các hiệu ứng chuyên nghiệp
class InteractiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool isLoading;

  const InteractiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 32,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveButton(
      icon: icon,
      onPressed: onPressed,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      width: size,
      height: size,
      isIconButton: true,
      tooltip: tooltip,
      isLoading: isLoading,
    );
  }
}

