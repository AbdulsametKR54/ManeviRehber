import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/theme_manager.dart';
import '../utils/language_manager.dart';

class FormLabel extends StatelessWidget {
  final String label;
  const FormLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colorScheme.outline.withValues(alpha: 0.5)),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const PrimaryButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: onTap == null
              ? [
                  colorScheme.outline.withValues(alpha: 0.3),
                  colorScheme.outline.withValues(alpha: 0.3),
                ]
              : [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          if (onTap != null)
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FooterKeyword extends StatelessWidget {
  final String text;
  const FooterKeyword({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        color: colorScheme.outline.withValues(alpha: 0.5),
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class FooterDot extends StatelessWidget {
  const FooterDot({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
    );
  }
}

class LoginDivider extends StatelessWidget {
  const LoginDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.or,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.outline,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // We don't import ThemeManager here to avoid circular dependencies if any,
    // but we can use Theme.of(context).brightness to determine the icon.
    // However, we need ThemeManager to actually toggle it.
    // Let's import it.
    return IconButton(
      onPressed: () {
        final themeManager = ThemeManager();
        themeManager.toggleTheme(themeManager.themeMode != ThemeMode.dark);
      },
      icon: Icon(
        Theme.of(context).brightness == Brightness.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final languageManager = LanguageManager();
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      onSelected: (String code) {
        languageManager.setLanguage(code);
      },
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlag(languageManager.locale.languageCode),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(
              languageManager.locale.languageCode.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildPopupItem('tr', '🇹🇷', 'Türkçe'),
        _buildPopupItem('en', '🇬🇧', 'English'),
        _buildPopupItem('ar', '🇸🇦', 'العربية'),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String code, String flag, String name) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇹🇷';
    }
  }
}
