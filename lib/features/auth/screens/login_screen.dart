import 'dart:developer' as developer;
import 'dart:math' as Math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/utils/validators.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/auth/widgets/auth_button.dart';
import 'package:watch2earn/features/auth/widgets/auth_text_field.dart';
import 'package:watch2earn/shared/widgets/app_logo.dart';

import '../../../core/theme/modern_widgets.dart';
import '../../../core/theme/text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Log when Login screen is initialized
    developer.log('LoginScreen initialized', name: 'LoginScreen');

    // Check if we need to redirect to home on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    final authState = ref.read(authControllerProvider);
    authState.whenData((state) {
      if (state.isAuthenticated) {
        developer.log('User already authenticated when login screen loaded, navigating to home',
            name: 'LoginScreen');
        if (mounted) {
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    developer.log('LoginScreen disposed', name: 'LoginScreen');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      developer.log('Login form validated, attempting login with email: ${_emailController.text.trim()}',
          name: 'LoginScreen');

      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } catch (e) {
        developer.log('Error during login: $e', name: 'LoginScreen', error: e);

        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login error: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      developer.log('Login form validation failed', name: 'LoginScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    developer.log('Building LoginScreen, authState: hasValue=${authState.hasValue}, hasError=${authState.hasError}, isLoading=${authState.isLoading}',
        name: 'LoginScreen');

    if (authState.hasValue) {
      developer.log('Auth state value: isAuthenticated=${authState.value?.isAuthenticated}, failure=${authState.value?.failure?.message}',
          name: 'LoginScreen');
    }

    // This listener ensures we react to auth state changes
    ref.listen(authControllerProvider, (previous, next) {
      developer.log('Auth state changed in LoginScreen',
          name: 'LoginScreen');

      // Skip if this is the initial build or still loading
      if (previous == null || next.isLoading) return;

      // Process auth state data
      next.whenData((state) {
        developer.log('Processing auth state in LoginScreen: isAuthenticated=${state.isAuthenticated}, failure=${state.failure}',
            name: 'LoginScreen');

        if (state.isAuthenticated) {
          developer.log('User is authenticated, navigating to home', name: 'LoginScreen');

          // Delay navigation to ensure UI is updated properly
          Future.microtask(() {
            if (mounted) {
              context.go('/home');
            }
          });
        } else if (state.failure != null) {
          developer.log('Authentication failed: ${state.failure!.message}', name: 'LoginScreen');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      });

      // Handle error state directly
      if (next.hasError) {
        developer.log('Auth state has error: ${next.error}', name: 'LoginScreen', error: next.error);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1F35),
              Color(0xFF0F1225),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logosu
                    const AppLogo(size: 100),
                    const SizedBox(height: 32),

                    // Hoşgeldiniz metni
                    GlassContainer(
                      color: Colors.white,
                      opacity: 0.05,
                      blur: 3,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      child: Text(
                        'auth.welcome'.tr(),
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // E-posta alanı
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'auth.email'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Şifre alanı
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'auth.password'.tr(),
                      isObscured: _isPasswordObscured,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 8),

                    // Beni hatırla ve şifremi unuttum
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                            Text(
                              'auth.remember_me'.tr(),
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password screen
                          },
                          child: Text('auth.forgot_password'.tr()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Giriş düğmesi
                    GradientButton(
                      text: 'auth.login'.tr(),
                      onPressed: _login,
                      isLoading: authState.isLoading,
                      colors: AppColors.primaryGradient,
                      elevation: 4,
                      height: 54,
                    ),
                    const SizedBox(height: 24),

                    // Hesap oluştur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.dont_have_account'.tr(),
                          style: AppTextStyles.bodyText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text('auth.register'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}