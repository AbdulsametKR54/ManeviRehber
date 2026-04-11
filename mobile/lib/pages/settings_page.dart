import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/theme_manager.dart';
import '../utils/language_manager.dart';
import '../services/user_service.dart';
import '../services/location_service.dart';
import '../utils/location_manager.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import 'profile_page.dart';
import 'location_selection_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserService _userService = UserService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final PrayerService _prayerService = PrayerService();

  Map<String, dynamic>? _userData;
  String _locationName = '...';
  bool _isLoadingData = true;

  bool _enableReminder15Min = true;
  bool _enableAthanSound = true;
  bool _enablePrayerWidget = false;

  @override
  void initState() {
    super.initState();
    LocationManager().addListener(_loadProfile);
    _loadProfile();
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    LocationManager().removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _enableReminder15Min = prefs.getBool('enable_prayer_reminder') ?? true;
        _enableAthanSound = prefs.getBool('enable_athan_sound') ?? true;
        _enablePrayerWidget = prefs.getBool('enable_prayer_widget') ?? false;
      });
    }
  }

  Future<void> _toggleNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (mounted) {
      setState(() {
        if (key == 'enable_prayer_reminder') _enableReminder15Min = value;
        if (key == 'enable_athan_sound') _enableAthanSound = value;
        if (key == 'enable_prayer_widget') _enablePrayerWidget = value;
      });
    }

    // Reschedule notifications
    final prayerTimes = await _prayerService.getTimes();
    if (prayerTimes != null) {
      if (key == 'enable_prayer_widget') {
        if (value) {
          await _notificationService.showPrayerTimesWidget(prayerTimes);
        } else {
          await _notificationService.removePrayerTimesWidget();
        }
      }
      await _notificationService.schedulePrayerNotifications(prayerTimes);
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingData = true);

    final results = await Future.wait([
      _userService.getProfile(),
      _locationService.getSelectedLocationName(),
    ]);

    if (mounted) {
      setState(() {
        _userData = results[0] as Map<String, dynamic>;
        _locationName = (results[1] as String?) ?? '';
        _isLoadingData = false;
      });
    }
  }

  String _getLanguageDisplay(String? langCode) {
    switch (langCode?.toLowerCase()) {
      case 'tr':
        return '🇹🇷 Türkçe';
      case 'en':
        return '🇬🇧 English';
      case 'ar':
        return '🇸🇦 العربية';
      default:
        return '🇹🇷 Türkçe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: isRtl ? null : -50,
            left: isRtl ? -50 : null,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Profil (Bilgilerim)
              _buildCardSection(
                context: context,
                title: l10n.settingsProfile,
                items: [
                  _isLoadingData
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _buildProfileCard(context, _userData),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Bildirimler (Bildirim Ayarları)
              _buildCardSection(
                context: context,
                title: l10n.notificationSettings,
                items: [
                  _buildSwitchItem(
                    context,
                    l10n.settingsReminder15Min,
                    _enableReminder15Min,
                    onChanged: (v) =>
                        _toggleNotificationSetting('enable_prayer_reminder', v),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildSwitchItem(
                    context,
                    l10n.settingsAthanSound,
                    _enableAthanSound,
                    onChanged: (v) =>
                        _toggleNotificationSetting('enable_athan_sound', v),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildSwitchItem(
                    context,
                    "Namaz Vaktini Bildirimde Göster", // Widget toggle
                    _enablePrayerWidget,
                    onChanged: (v) =>
                        _toggleNotificationSetting('enable_prayer_widget', v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Genel (Genel Ayarlar)
              _buildCardSection(
                context: context,
                title: l10n.generalSettings,
                items: [
                  _buildDropdownItem(
                    context: context,
                    label: l10n.languageTitle,
                    value: _getLanguageDisplay(
                      Localizations.localeOf(context).languageCode,
                    ),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildDropdownItem(
                    context: context,
                    label: l10n.settingsLocation,
                    value: _locationName.isEmpty ? l10n.unknown : _locationName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationSelectionPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Görünüm
              ListenableBuilder(
                listenable: themeManager,
                builder: (context, _) {
                  return _buildCardSection(
                    context: context,
                    title: l10n.settingsDailyContent, // Appearance/View
                    items: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.settingsTheme, style: textTheme.bodyLarge),
                          SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text(l10n.settingsThemeLight),
                                icon: const Icon(Icons.light_mode_outlined),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text(l10n.settingsThemeDark),
                                icon: const Icon(Icons.dark_mode_outlined),
                              ),
                            ],
                            selected: {themeManager.themeMode},
                            onSelectionChanged: (Set<ThemeMode> newSelection) {
                              themeManager.setThemeMode(newSelection.first);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.settingsBgTheme,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildColorPalette(context, themeManager),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildLinkItem(context, l10n.settingsAbout, onTap: () {}),
              _buildLinkItem(context, l10n.settingsPrivacy, onTap: () {}),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  l10n.versionInfo("1.0.0"),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Map<String, dynamic>? data) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: colorScheme.primary,
          child: Text(
            (data?['name'] ?? data?['Name'] ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data?['name'] ?? data?['Name'] ?? 'Hesabım',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data?['email'] ?? '...',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownItem({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String label,
    bool value, {
    ValueChanged<bool>? onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildColorPalette(BuildContext context, ThemeManager themeManager) {
    final colors = [
      const Color(0xFF6200EE),
      const Color(0xFF03DAC6),
      const Color(0xFFF44336),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        final isSelected =
            themeManager.primaryColor.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => themeManager.setPrimaryColor(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    String label, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context)!.languageTitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          children: [
            _buildLanguageOption(context, 'TR', '🇹🇷 Türkçe'),
            _buildLanguageOption(context, 'EN', '🇬🇧 English'),
            _buildLanguageOption(context, 'AR', '🇸🇦 العربية'),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name) {
    final languageManager = LanguageManager();
    final isSelected =
        Localizations.localeOf(context).languageCode == code.toLowerCase();

    return SimpleDialogOption(
      onPressed: () async {
        await languageManager.setLanguage(code.toLowerCase());
        if (mounted) {
          // Trigger backend update
          await _userService.updateProfile(language: code.toLowerCase());
          Navigator.pop(context);
          setState(() {}); // Refresh local UI if needed
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          if (isSelected)
            Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
        ],
      ),
    );
  }
}
