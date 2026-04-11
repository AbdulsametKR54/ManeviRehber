import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'widgets/auth_widgets.dart';
import 'constants/app_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _selectedLanguage = 'TR';
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    final result = await _authService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      _selectedLanguage,
    );

    setState(() => _isLoading = false);

    if (result["id"] != null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.registerSuccess)));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final errorMessage = result["error"] ?? l10n.registerFail;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const RegisterHeader(),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(4, 8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormLabel(label: l10n.fullName),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: nameController,
                              hintText: l10n.fullNameHint,
                            ),
                            const SizedBox(height: 24),
                            FormLabel(label: l10n.email),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: emailController,
                              hintText: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),
                            FormLabel(label: l10n.password),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: passwordController,
                              hintText: '••••••••',
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),
                            FormLabel(label: l10n.language),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLanguage,
                                  isExpanded: true,
                                  dropdownColor: colorScheme.surface,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: colorScheme.outline,
                                  ),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedLanguage = newValue!;
                                    });
                                  },
                                  items: <String>['TR', 'EN', 'AR']
                                      .map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        String flag = '🇹🇷';
                                        if (value == 'EN') flag = '🇬🇧';
                                        if (value == 'AR') flag = '🇸🇦';
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Row(
                                            children: [
                                              Text(flag),
                                              const SizedBox(width: 8),
                                              Text(value),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            PrimaryButton(
                              text: _isLoading
                                  ? l10n.registering
                                  : l10n.registerButton,
                              onTap: _isLoading ? null : _handleRegister,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const LoginDivider(),
                      const SizedBox(height: 32),
                      const RegisterGoogleButton(),
                      const SizedBox(height: 48),
                      const RegisterFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [
                  const LanguageToggleButton(),
                  const SizedBox(width: 8),
                  const ThemeToggleButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(4.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(4, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Image.asset(
            AppConstants.appLogo,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.registerTitle,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -1,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.registerWelcome,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.outline,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class RegisterGoogleButton extends StatelessWidget {
  const RegisterGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png', // Generic Google Icon
            height: 20,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.continueWithGoogle,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: 13,
                fontFamily: 'Manrope',
              ),
              children: [
                TextSpan(text: '${l10n.hasAccount} '),
                TextSpan(
                  text: l10n.loginNow,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FooterKeyword(text: l10n.serenity),
            const FooterDot(),
            FooterKeyword(text: l10n.faith),
            const FooterDot(),
            FooterKeyword(text: l10n.belief),
          ],
        ),
      ],
    );
  }
}
