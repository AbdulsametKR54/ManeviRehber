import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RegisterHeader(),
                  SizedBox(height: 48),
                  RegisterFormCard(),
                  SizedBox(height: 32),
                  LoginDivider(),
                  SizedBox(height: 32),
                  RegisterGoogleButton(),
                  SizedBox(height: 48),
                  RegisterFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(4.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
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
        const Text(
          'Kayıt Ol',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1C),
            letterSpacing: -1,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Yeni bir yolculuğa başlayın.',
          style: TextStyle(fontSize: 14, color: Color(0xFF3E4941), height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class RegisterFormCard extends StatefulWidget {
  const RegisterFormCard({super.key});

  @override
  State<RegisterFormCard> createState() => _RegisterFormCardState();
}

class _RegisterFormCardState extends State<RegisterFormCard> {
  String _selectedLanguage = 'Türkçe';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const FormLabel(label: 'AD SOYAD'),
          const SizedBox(height: 8),
          const CustomTextField(hintText: 'Ad Soyad'),
          const SizedBox(height: 24),
          const FormLabel(label: 'E-POSTA'),
          const SizedBox(height: 8),
          const CustomTextField(
            hintText: 'örnek@mail.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          const FormLabel(label: 'ŞİFRE'),
          const SizedBox(height: 8),
          const CustomTextField(hintText: '••••••••', obscureText: true),
          const SizedBox(height: 24),
          const FormLabel(label: 'DİL'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF3E4941),
                ),
                style: const TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
                items: <String>['Türkçe', 'English']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const PrimaryButton(text: 'Kayıt Ol'),
        ],
      ),
    );
  }
}

class RegisterGoogleButton extends StatelessWidget {
  const RegisterGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: const Color(0xFFBDCABE).withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png', // Generic Google Icon
            height: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'Google ile devam et',
            style: TextStyle(
              color: Color(0xFF1A1C1C),
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
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Color(0xFF3E4941),
                fontSize: 13,
                fontFamily: 'Manrope',
              ),
              children: [
                TextSpan(text: 'Zaten hesabın var mı? '),
                TextSpan(
                  text: 'Giriş yap',
                  style: TextStyle(
                    color: Color(0xFF006A40),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FooterKeyword(text: 'Huzur'),
            FooterDot(),
            FooterKeyword(text: 'İnanç'),
            FooterDot(),
            FooterKeyword(text: 'İman'),
          ],
        ),
      ],
    );
  }
}
