import 'dart:developer' as developer;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/modern_widgets.dart';
import 'package:watch2earn/core/theme/text_styles.dart';
import 'package:watch2earn/core/utils/validators.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/auth/services/credentials_storage.dart';
import 'package:watch2earn/features/auth/widgets/auth_button.dart';
import 'package:watch2earn/features/auth/widgets/auth_text_field.dart';
import 'package:watch2earn/shared/widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    developer.log('LoginScreen initialized', name: 'LoginScreen');

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();

    // Check if we need to redirect to home on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
      _loadSavedCredentials();
    });
  }

  // Load saved credentials and remember me preference
  Future<void> _loadSavedCredentials() async {
    try {
      final credentialsStorage = ref.read(credentialsStorageProvider);

      // Get the remember me preference
      final rememberMe = await credentialsStorage.getRememberMePreference();

      if (rememberMe) {
        // If remember me was selected, get saved credentials
        final savedCredentials = await credentialsStorage.getSavedCredentials();

        if (savedCredentials != null) {
          // Set email and password fields if credentials exist
          setState(() {
            _emailController.text = savedCredentials['email'] ?? '';
            _passwordController.text = savedCredentials['password'] ?? '';
            _rememberMe = true;
          });

          developer.log('Loaded saved credentials for ${_emailController.text}',
              name: 'LoginScreen');
        }
      }
    } catch (e) {
      developer.log('Error loading saved credentials: $e',
          name: 'LoginScreen', error: e);
    }
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
    _animationController.dispose();
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
        // Save credentials if remember me is checked
        final credentialsStorage = ref.read(credentialsStorageProvider);
        await credentialsStorage.saveCredentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

        // Perform login
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
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final theme = Theme.of(context);

    // Apply listener to handle auth state changes
    ref.listen(authControllerProvider, (previous, next) {
      // Skip if this is the initial build or still loading
      if (previous == null || next.isLoading) return;

      // Process auth state data
      next.whenData((state) {
        if (state.isAuthenticated) {
          // Delay navigation to ensure UI is updated properly
          Future.microtask(() {
            if (mounted) {
              context.go('/home');
            }
          });
        } else if (state.failure != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor,
                  theme.colorScheme.background,
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),

          // Background circles for visual interest
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentColor.withOpacity(0.15),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App logo
                          const Center(
                            child: AppLogo(size: 100, useGradient: false),
                          ),
                          const SizedBox(height: 24),

                          // Welcome text
                          Center(
                            child: GlassContainer(
                              color: Colors.white,
                              opacity: 0.1,
                              blur: 5,
                              borderRadius: 20,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              child: Text(
                                'auth.welcome'.tr(),
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Login card
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'auth.login'.tr(),
                                    style: AppTextStyles.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Email field
                                  AuthTextField(
                                    controller: _emailController,
                                    hintText: 'auth.email'.tr(),
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator: Validators.validateEmail,
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
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
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _login(),
                                  ),
                                  const SizedBox(height: 8),

                                  // Remember me and forgot password
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
                                            style: AppTextStyles.bodyTextSmall,
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

                                  // Login button
                                  GradientButton(
                                    text: 'auth.login'.tr(),
                                    onPressed: _login,
                                    isLoading: authState.isLoading,
                                    colors: AppColors.primaryGradient,
                                    elevation: 4,
                                    height: 54,
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'auth.dont_have_account'.tr(),
                                style: AppTextStyles.bodyText.copyWith(
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: Text(
                                  'auth.register'.tr(),
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}