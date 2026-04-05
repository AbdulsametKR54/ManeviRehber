import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/daily_content_service.dart';
import '../services/quran_service.dart';
import '../models/daily_content_model.dart';
import '../models/daily_verse_model.dart';
import '../utils/image_utils.dart';
import '../l10n/generated/app_localizations.dart';
import '../pages/daily_share_preview_page.dart';

class DailyContentPage extends StatefulWidget {
  const DailyContentPage({super.key});

  @override
  State<DailyContentPage> createState() => _DailyContentPageState();
}

class _DailyContentPageState extends State<DailyContentPage> {
  final DailyContentService _dailyContentService = DailyContentService();
  final QuranService _quranService = QuranService();

  DailyVerseModel? _verse;
  DailyContentModel? _quote;
  bool _isLoading = true;
  late String _bgImage;

  @override
  void initState() {
    super.initState();
    _bgImage = ImageUtils.getRandomDiniImage();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _quranService.getRandomAyah(),
        _dailyContentService.getRandomDailyContent(),
      ]);
      if (mounted) {
        setState(() {
          _verse = results[0] as DailyVerseModel?;
          _quote = results[1] as DailyContentModel?;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("DailyContentPage Fetch Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFormattedDate(BuildContext context) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;
    // Better way: use intl DateFormat
    return "${now.day} ${_getMonthName(now.month, l10n)} ${now.year}";
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.month1;
      case 2: return l10n.month2;
      case 3: return l10n.month3;
      case 4: return l10n.month4;
      case 5: return l10n.month5;
      case 6: return l10n.month6;
      case 7: return l10n.month7;
      case 8: return l10n.month8;
      case 9: return l10n.month9;
      case 10: return l10n.month10;
      case 11: return l10n.month11;
      case 12: return l10n.month12;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              // Hero Section
              Stack(
                children: [
                   Container(
                    height: 400,
                    width: double.infinity,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Image.asset(
                      _bgImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: colorScheme.outline),
                    ),
                  ),
                  Positioned(
                    bottom: 48,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          _getFormattedDate(context).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.dailyContentHeader,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Noto Serif',
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close/Back Button if needed, or top bar icons
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Section: Ayah (Verse)
              Transform.translate(
                offset: const Offset(0, -32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.contentTypeAyah,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Divider(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _verse?.surahName ?? 'Sabır ve Umut',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontFamily: 'Noto Serif',
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _verse?.arabic ?? '',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontFamily: 'Amiri',
                                fontSize: 32,
                                height: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _verse?.translation ?? '',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontFamily: 'Noto Serif',
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${(_verse?.surahName ?? '').toUpperCase()}, ${_verse?.ayahNumber ?? ''}",
                            style: TextStyle(
                              color: colorScheme.outline,
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_verse != null)
                                IconButton(
                                  icon: const Icon(Icons.share_outlined, size: 20),
                                  color: colorScheme.primary,
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DailySharePreviewPage(
                                          title: _verse!.surahName,
                                          content: _verse!.translation,
                                          subtitle: "${_verse!.surahName} ${_verse!.ayahNumber}",
                                          category: "Verse",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(width: 8),
                              _buildCardAction(context, Icons.bookmark_border, AppLocalizations.of(context)!.save),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                            Text(
                              AppLocalizations.of(context)!.contentTypeQuote,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Divider(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _quote?.title ?? AppLocalizations.of(context)!.dailyQuote,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontFamily: 'Noto Serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        Text(
                          _quote?.content ?? '',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                _quote?.typeName ?? AppLocalizations.of(context)!.spiritualPearls,
                              style: TextStyle(
                                color: colorScheme.outline,
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share_outlined, size: 20),
                                  color: colorScheme.primary,
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    if (_quote != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DailySharePreviewPage(
                                            title: _quote!.title,
                                            content: _quote!.content,
                                            subtitle: _quote!.title, // Use author/title as subtitle
                                            category: _quote!.typeName,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildCardAction(context, Icons.bookmark_border, AppLocalizations.of(context)!.save),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
              Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardAction(BuildContext context, IconData icon, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
        );
      },
      icon: Icon(icon, size: 20),
      color: colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
