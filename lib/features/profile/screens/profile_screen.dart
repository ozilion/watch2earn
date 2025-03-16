import 'dart:developer' as developer;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/profile/widgets/profile_menu_item.dart';
import 'package:watch2earn/features/profile/widgets/token_balance_widget.dart';
import 'package:watch2earn/features/profile/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('ProfileScreen initialized', name: 'ProfileScreen');
    // Check authentication status when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  @override
  void dispose() {
    developer.log('ProfileScreen disposed', name: 'ProfileScreen');
    super.dispose();
  }

  void _checkAuthStatus() {
    final authState = ref.read(authControllerProvider);
    authState.whenData((state) {
      developer.log('Checking auth status in ProfileScreen: isAuthenticated=${state.isAuthenticated}, user=${state.user != null}',
          name: 'ProfileScreen');

      if (!state.isAuthenticated || state.user == null) {
        developer.log('User not authenticated, should navigate to login', name: 'ProfileScreen');
        // Router's redirect should handle this, but we can add additional checks here
      }
    });
  }

  // Handles logout with proper navigation
  Future<void> _handleLogout() async {
    developer.log('Logout button pressed', name: 'ProfileScreen');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Perform logout
      await ref.read(authControllerProvider.notifier).logout();

      // Close loading indicator if still mounted
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Let the router handle navigation based on auth state
      developer.log('Logout successful, router should handle navigation', name: 'ProfileScreen');
    } catch (e) {
      // Close loading indicator if still mounted
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }

      developer.log('Logout failed: $e', name: 'ProfileScreen', error: e);
    }
  }

  // Handles login navigation
  void _navigateToLogin() {
    developer.log('Login button pressed in ProfileScreen, navigating to login', name: 'ProfileScreen');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    developer.log('Building ProfileScreen, authState: hasValue=${authState.hasValue}, hasError=${authState.hasError}, isLoading=${authState.isLoading}',
        name: 'ProfileScreen');

    if (authState.hasValue) {
      developer.log('Auth state value: isAuthenticated=${authState.value?.isAuthenticated}, user=${authState.value?.user != null}',
          name: 'ProfileScreen');
    }

    // Listen for authentication changes
    ref.listen<AsyncValue>(authControllerProvider, (previous, current) {
      // Skip if this is the initial build
      if (previous == null) return;

      developer.log('Auth state changed in ProfileScreen', name: 'ProfileScreen');

      current.whenData((state) {
        if (!state.isAuthenticated && mounted) {
          developer.log('User logged out, router should handle navigation to login screen', name: 'ProfileScreen');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('profile.title'.tr()),
      ),
      body: authState.when(
        data: (state) {
          // If user isn't authenticated, show login prompt
          if (state.user == null) {
            developer.log('Rendering login prompt in ProfileScreen', name: 'ProfileScreen');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to view your profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _navigateToLogin,
                    child: Text('auth.login'.tr()),
                  ),
                ],
              ),
            );
          }

          // User is authenticated, show profile
          developer.log('Rendering profile for user: ${state.user?.name}', name: 'ProfileScreen');
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      UserAvatar(
                        imageUrl: state.user!.profileImageUrl,
                        name: state.user!.name,
                        size: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.user!.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.user!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TokenBalanceWidget(
                        balance: state.user!.tokenBalance,
                        onTap: () => context.go('/rewards'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ProfileMenuItem(
                  icon: Icons.edit,
                  title: 'profile.edit_profile'.tr(),
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.list,
                  title: 'watchlist.title'.tr(),
                  onTap: () => context.go('/profile/watchlist'),
                ),
                ProfileMenuItem(
                  icon: Icons.monetization_on,
                  title: 'profile.token_history'.tr(),
                  onTap: () => context.go('/rewards'),
                ),
                ProfileMenuItem(
                  icon: Icons.settings,
                  title: 'settings.title'.tr(),
                  onTap: () => context.go('/profile/settings'),
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'profile.help'.tr(),
                  onTap: () {
                    // Navigate to help
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'profile.about'.tr(),
                  onTap: () {
                    // Navigate to about
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text('auth.logout'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),

                // DEBUG SECTION - Remove in production
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.grey.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Is Authenticated: ${state.isAuthenticated}'),
                      Text('User: ${state.user?.name}'),
                      Text('Current Route: ${GoRouter.of(context).location}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          developer.log('Error in ProfileScreen: $error', name: 'ProfileScreen', error: error, stackTrace: stackTrace);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(authControllerProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}