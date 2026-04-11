import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/quran_constants.dart';
import 'hatim_page.dart';

class JuzListPage extends StatelessWidget {
  const JuzListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              title: Text(
                "Cüzler",
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
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            int juzNumber = index + 1;
            int startPage = QuranConstants.juzToPage[juzNumber]!;
            
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HatimPage(initialPage: startPage),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.surfaceVariant, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$juzNumber",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$juzNumber. Cüz",
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Noto Serif',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Sayfa $startPage",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
