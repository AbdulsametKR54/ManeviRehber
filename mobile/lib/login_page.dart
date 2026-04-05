import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result["token"] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result["token"]);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final errorMessage = result["error"] ?? l10n.loginFail;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage.toString())),
        );
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
                      const LoginHeader(),
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
                            FormLabel(label: l10n.email),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: emailController,
                              hintText: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FormLabel(label: l10n.password),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.outline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: passwordController,
                              hintText: '••••••••',
                              obscureText: true,
                            ),
                            const SizedBox(height: 32),
                            PrimaryButton(
                              text: _isLoading ? l10n.loggingIn : l10n.loginButton,
                              onTap: _isLoading ? null : _handleLogin,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const LoginDivider(),
                      const SizedBox(height: 32),
                      const GoogleLoginButton(),
                      const SizedBox(height: 48),
                      const LoginFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(child: const ThemeToggleButton()),
          ),
        ],
      ),
    );

  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

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
            'assets/logo/Manevi-Rehber-Icon.png',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.appName,
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
          l10n.loginWelcome,
          style: TextStyle(fontSize: 14, color: colorScheme.outline, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// LoginDivider and GoogleLoginButton are used here.
// LoginDivider is now in auth_widgets.dart

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

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

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: colorScheme.outline, fontSize: 13, fontFamily: 'Manrope'),
              children: [
                TextSpan(text: '${l10n.noAccount} '),
                TextSpan(
                  text: l10n.registerNow,
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
