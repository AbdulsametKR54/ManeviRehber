import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../services/daily_content_service.dart';
import '../models/surah_model.dart';
import '../models/daily_content_model.dart';
import 'surah_detail_page.dart';
import '../utils/image_utils.dart';
import '../l10n/generated/app_localizations.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> with SingleTickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  final DailyContentService _dailyContentService = DailyContentService();

  List<SurahModel> _surahs = [];
  List<SurahModel> _filteredSurahs = [];
  DailyContentModel? _dailyQuote;
  bool _isLoading = true;
  late String _bgImage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bgImage = ImageUtils.getRandomDiniImage();
    _fetchData();
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _bgImage = ImageUtils.getRandomDiniImage();
    });
    try {
      final results = await Future.wait([
        _quranService.getSurahs(),
        _dailyContentService.getDailyContentByTag('Kuran'),
      ]);

      if (mounted) {
        setState(() {
          _surahs = results[0] as List<SurahModel>;
          _filteredSurahs = _surahs;
          _dailyQuote = results[1] as DailyContentModel?;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('SurahListPage _fetchData Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs = _surahs.where((surah) {
        return surah.turkishName.toLowerCase().contains(query) ||
            surah.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: colorScheme.background.withValues(alpha: 0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppLocalizations.of(context)!.quranHeader,
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: colorScheme.onSurface),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Section
                _buildSearchField(context),
                const SizedBox(height: 32),
                // Hero Section
                _buildHeroCard(),
                const SizedBox(height: 40),
                // Surah List
                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: colorScheme.primary))
                else
                  ..._filteredSurahs.map((surah) => _buildSurahCard(context, surah)).toList(),
                
                if (!_isLoading && _filteredSurahs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(AppLocalizations.of(context)!.surahNotFound, style: TextStyle(color: colorScheme.outline)),
                    ),
                  ),
                
                // Continuous Scroll Indicator
                const SizedBox(height: 32),
                Center(child: _buildScrollIndicator(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontFamily: 'Manrope', color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchSurah,
          hintStyle: TextStyle(color: colorScheme.outline),
          prefixIcon: Icon(Icons.search, color: colorScheme.outline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _bgImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.auto_stories, size: 120, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dailyQuote?.content ?? '"Şüphesiz bu Kur’an, en doğru yola iletir."',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _dailyQuote?.title.toUpperCase() ?? 'İSRÂ SURESİ, 9. AYET',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, SurahModel surah) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(surah: surah),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.surfaceVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.id}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.turkishName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.ayahCount(surah.ayahCount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${AppLocalizations.of(context)!.detail} ->',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
