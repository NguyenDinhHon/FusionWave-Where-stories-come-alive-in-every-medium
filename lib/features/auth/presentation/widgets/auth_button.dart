import 'package:flutter/material.dart';
import '../../../../core/widgets/interactive_button.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveButton(
      label: text,
      icon: icon,
      onPressed: isLoading ? null : onPressed,
      isLoading: isLoading,
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}

