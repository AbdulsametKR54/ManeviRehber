import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'surah_list_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: colorScheme.background.withValues(alpha: 0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                l10n.quranHeader,
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                "Keşfet",
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Kur'an-ı Kerim dünyasına adım atın",
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Manrope',
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      title: "Sureler",
                      subtitle: "114 Sure",
                      icon: Icons.menu_book_rounded,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SurahListPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: "Cüzler",
                      subtitle: "30 Cüz",
                      icon: Icons.grid_view_rounded,
                      color: Colors.amber.shade700,
                      onTap: () {
                        _showSoonSnackBar(context);
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: "Son Okunan",
                      subtitle: "Kaldığın yerden devam et",
                      icon: Icons.history_rounded,
                      color: Colors.blue,
                      onTap: () {
                        _showSoonSnackBar(context);
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: "Favoriler",
                      subtitle: "Kaydettiğin ayetler",
                      icon: Icons.bookmark_rounded,
                      color: Colors.pink,
                      onTap: () {
                        _showSoonSnackBar(context);
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: "Hatmi Şerif",
                      subtitle: "Hatim takibi yap",
                      icon: Icons.auto_stories_rounded,
                      color: Colors.purple,
                      onTap: () {
                        _showSoonSnackBar(context);
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: "Dinle",
                      subtitle: "Kıraat ve dinleme",
                      icon: Icons.headset_rounded,
                      color: Colors.teal,
                      onTap: () {
                        _showSoonSnackBar(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.surfaceVariant, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Noto Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bu özellik yakında eklenecek"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
