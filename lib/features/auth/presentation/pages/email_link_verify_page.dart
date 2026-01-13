import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../providers/auth_provider.dart';

/// Page to verify email link and complete sign-in
class EmailLinkVerifyPage extends ConsumerStatefulWidget {
  final String? email;
  final String? link;
  
  const EmailLinkVerifyPage({
    super.key,
    this.email,
    this.link,
  });

  @override
  ConsumerState<EmailLinkVerifyPage> createState() => _EmailLinkVerifyPageState();
}

class _EmailLinkVerifyPageState extends ConsumerState<EmailLinkVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
    
    // Auto-verify if both email and link are provided
    if (widget.email != null && widget.link != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyEmailLink(widget.email!, widget.link!);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmailLink(String email, String link) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isVerifying = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).signInWithEmailLink(
        email: email,
        link: link,
      );
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = widget.link ?? Uri.base.toString();
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Icon
                const Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  _isVerifying ? 'Verifying...' : 'Verify Email Link',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isVerifying
                      ? 'Please wait while we verify your email link...'
                      : 'Enter your email to complete sign-in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isVerifying,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Verify Button
                if (!_isVerifying)
                  AuthButton(
                    text: 'Verify Email Link',
                    onPressed: _isLoading ? null : () {
                      _verifyEmailLink(_emailController.text.trim(), link);
                    },
                    isLoading: _isLoading,
                  ),
                
                if (_isVerifying)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                
                const SizedBox(height: 24),
                
                // Back to Login
                TextButton(
                  onPressed: _isVerifying ? null : () => context.go('/login'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

