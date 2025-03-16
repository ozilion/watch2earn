import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/settings/providers/language_provider.dart';
import 'package:watch2earn/features/settings/providers/theme_provider.dart';
import 'package:watch2earn/features/settings/widgets/settings_list_tile.dart';
import 'package:watch2earn/features/settings/widgets/settings_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }
  
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }
  
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => LanguageSelectionDialog(
        onLanguageSelected: (language) {
          ref.read(languageProvider.notifier).setLanguage(
                context,
                Locale(language.code),
              );
          Navigator.pop(context);
        },
      ),
    );
  }
  
  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectionDialog(
        onThemeSelected: (theme) {
          ref.read(themeProvider.notifier).setThemeMode(theme);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auth.logout'.tr()),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('general.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text('auth.logout'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final language = supportedLanguages.firstWhere(
      (lang) => lang.code == currentLanguage.languageCode,
      orElse: () => supportedLanguages.first,
    );
    
    final themeMode = ref.watch(themeProvider);
    String themeName;
    switch (themeMode) {
      case ThemeMode.light:
        themeName = 'settings.light'.tr();
        break;
      case ThemeMode.dark:
        themeName = 'settings.dark'.tr();
        break;
      case ThemeMode.system:
        themeName = 'settings.system'.tr();
        break;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          SettingsSection(
            title: 'settings.title'.tr(),
            children: [
              SettingsListTile(
                icon: Icons.language,
                title: 'settings.language'.tr(),
                subtitle: '${language.flag} ${language.name}',
                onTap: _showLanguageSelectionDialog,
              ),
              SettingsListTile(
                icon: Icons.color_lens,
                title: 'settings.theme'.tr(),
                subtitle: themeName,
                onTap: _showThemeSelectionDialog,
              ),
              SettingsListTile(
                icon: Icons.notifications,
                title: 'settings.notifications'.tr(),
                trailing: Switch(
                  value: true, // This would be from a provider in a real app
                  onChanged: (value) {
                    // Update notification settings
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: [
              SettingsListTile(
                icon: Icons.privacy_tip,
                title: 'settings.privacy'.tr(),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              SettingsListTile(
                icon: Icons.description,
                title: 'settings.terms'.tr(),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              SettingsListTile(
                icon: Icons.info,
                title: 'settings.version'.tr(),
                subtitle: _appVersion,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.exit_to_app),
              label: Text('auth.logout'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSelectionDialog extends StatelessWidget {
  final Function(Language) onLanguageSelected;
  
  const LanguageSelectionDialog({
    Key? key,
    required this.onLanguageSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('settings.language'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: supportedLanguages.length,
          itemBuilder: (context, index) {
            final language = supportedLanguages[index];
            return ListTile(
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(language.name),
              onTap: () => onLanguageSelected(language),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('general.cancel'.tr()),
        ),
      ],
    );
  }
}

class ThemeSelectionDialog extends StatelessWidget {
  final Function(ThemeMode) onThemeSelected;
  
  const ThemeSelectionDialog({
    Key? key,
    required this.onThemeSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('settings.theme'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_5),
            title: Text('settings.light'.tr()),
            onTap: () => onThemeSelected(ThemeMode.light),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_4),
            title: Text('settings.dark'.tr()),
            onTap: () => onThemeSelected(ThemeMode.dark),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: Text('settings.system'.tr()),
            onTap: () => onThemeSelected(ThemeMode.system),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('general.cancel'.tr()),
        ),
      ],
    );
  }
}
