import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/quran_constants.dart';
import '../services/quran_service.dart';
import '../models/surah_model.dart';
import '../utils/image_utils.dart';
import '../models/quran_page_model.dart';
import '../l10n/generated/app_localizations.dart';
import 'daily_share_preview_page.dart';
import '../services/favorite_service.dart';
import '../models/favorite_model.dart';

class HatimPage extends StatefulWidget {
  final int initialPage;
  const HatimPage({super.key, this.initialPage = 1});

  @override
  State<HatimPage> createState() => _HatimPageState();
}

class _HatimPageState extends State<HatimPage> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showControls = true;
  List<SurahModel> _surahs = [];
  final QuranService _quranService = QuranService();
  final FavoriteService _favoriteService = FavoriteService();
  String _bgImage = '';
  List<FavoriteModel> _userFavorites = [];
  final Map<int, List<AcikKuranVerse>> _pageCache = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    // Quran mushaf is RTL, so we use reverse: true
    // Page 1 should be the index 0 in the builder, but effectively the last in RTL view?
    // Actually, in Flutter PageView(reverse: true), index 0 is on the far RIGHT.
    // Page 1 (Mushaf) is index 0.
    _pageController = PageController(initialPage: _currentPage - 1);
    _bgImage = ImageUtils.getRandomCamiImage();
    _loadSurahs();
    _loadLastPage();
  }

  Future<void> _loadLastPage() async {
    if (widget.initialPage == 1) {
      final prefs = await SharedPreferences.getInstance();
      print('HatimPage: Loading last page from prefs...');
      final lastPage = prefs.getInt('last_hatim_page') ?? 1;
      print('HatimPage: Last page found: $lastPage');
      if (mounted && lastPage != _currentPage) {
        setState(() {
          _currentPage = lastPage;
        });
        _pageController.jumpToPage(_currentPage - 1);
      } else if (mounted && _currentPage == 1) {
        // Force jump to 0 just in case the PageView didn't initialize correctly
        _pageController.jumpToPage(0);
      }
    }
  }

  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_hatim_page', page);
  }

  Future<void> _loadSurahs() async {
    final results = await Future.wait([
      _quranService.getSurahs(),
      _favoriteService.getFavorites(),
    ]);

    if (mounted) {
      setState(() {
        _surahs = results[0] as List<SurahModel>;
        _userFavorites = results[1] as List<FavoriteModel>;
      });
    }
  }

  void _toggleFavoriteHatim(AcikKuranVerse verse) async {
    final externalId = "${verse.surah.id}:${verse.verseNumber}";
    final existingIndex = _userFavorites.indexWhere((f) => f.externalId == externalId && f.type == 1);

    if (existingIndex != -1) {
      final favoriteId = _userFavorites[existingIndex].id;
      final success = await _favoriteService.deleteFavorite(favoriteId);
      if (success && mounted) {
        setState(() {
          _userFavorites.removeAt(existingIndex);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorilerden kaldırıldı')),
        );
      }
    } else {
      final favorite = FavoriteModel(
        id: "",
        type: 1, // Verse
        externalId: externalId,
        surahId: verse.surah.id,
        ayahNumber: verse.verseNumber,
        title: "${verse.surah.name} ${verse.verseNumber}",
        contentArabic: verse.verse,
        contentText: verse.translation.text,
        createdAt: DateTime.now(),
      );

      final success = await _favoriteService.addFavorite(favorite);
      if (success && mounted) {
        final updatedFavs = await _favoriteService.getFavorites();
        if (mounted) {
          setState(() {
            _userFavorites = updatedFavs;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorilere eklendi')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getSurahName(int page) {
    int surahId = QuranConstants.getSurahByPage(page);
    if (_surahs.isEmpty) return '...';
    final surah = _surahs.firstWhere((s) => s.id == surahId, orElse: () => _surahs.first);
    return surah.turkishName;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Subtle texture or clean background
          Positioned.fill(
            child: Container(
              color: colorScheme.surface,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(_bgImage, fit: BoxFit.cover), // Keep a very subtle hint of background
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: PageView.builder(
              controller: _pageController,
              itemCount: QuranConstants.totalPages,
              reverse: true, // Quran is RTL
              onPageChanged: (index) {
                final page = index + 1;
                setState(() => _currentPage = page);
                _saveLastPage(page);
              },
              itemBuilder: (context, index) {
                final page = index + 1;
                return _buildPage(page);
              },
            ),
          ),

          // Top Info Bar
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context, l10n, colorScheme, textTheme),
            ),

          // Bottom Navigation / Jump Bar
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context, l10n, colorScheme, textTheme),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme, TextTheme textTheme) {
    final surahName = _getSurahName(_currentPage);
    final juz = QuranConstants.getJuzByPage(_currentPage);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 12, left: 16, right: 16),
          color: colorScheme.surface.withValues(alpha: 0.8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      surahName,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Noto Serif',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cüz $juz • Sayfa $_currentPage',
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'Manrope',
                        color: colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                onPressed: _showTOC,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme, TextTheme textTheme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 12, top: 12, left: 24, right: 24),
          color: colorScheme.surface.withValues(alpha: 0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _showTOC,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: _buildNavInfo('Cüz', '${QuranConstants.getJuzByPage(_currentPage)}'),
                ),
              ),
              InkWell(
                onTap: _showPagePicker,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: _buildNavInfo('Sıra', '$_currentPage / 604'),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _showControls = false),
                    icon: Icon(Icons.auto_stories_rounded, color: colorScheme.primary),
                    tooltip: 'Okuma Modu',
                  ),
                  Text(
                    'OKUMA MODU',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavInfo(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(
          fontSize: 10, 
          letterSpacing: 1.2, 
          fontWeight: FontWeight.bold,
          color: colorScheme.outline
        )),
        Text(value, style: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w900,
          fontFamily: 'Manrope'
        )),
      ],
    );
  }

  Widget _buildPage(int page) {
    if (_pageCache.containsKey(page)) {
      return _buildVerseList(_pageCache[page]!);
    }

    return FutureBuilder<List<AcikKuranVerse>>(
      future: _quranService.getPageVerses(page),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  'Sayfa $page Yükleniyor...',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorWidget(page);
        }

        _pageCache[page] = snapshot.data!;
        return _buildVerseList(snapshot.data!);
      },
    );
  }

  Widget _buildVerseList(List<AcikKuranVerse> verses) {
    if (verses.isEmpty) return const SizedBox();
    
    // Group verses by surah for headers
    Map<int, List<AcikKuranVerse>> groupedVerses = {};
    for (var v in verses) {
      groupedVerses.putIfAbsent(v.surah.id, () => []).add(v);
    }

    // Sort surahs by ID to ensure correct display order
    final sortedSurahIds = groupedVerses.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),
      child: Column(
        children: sortedSurahIds.map((surahId) {
          final surahVerses = groupedVerses[surahId]!;
          final firstVerse = surahVerses.first;
          
          return Column(
            children: [
              _buildSurahHeader(firstVerse.surah),
              if (firstVerse.zero != null) _buildBismillah(firstVerse.zero!),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: _buildMushafText(surahVerses),
              ),
              const SizedBox(height: 40),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMushafText(List<AcikKuranVerse> verses) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          children: verses.map((v) => _buildVerseSpan(v)).toList(),
        ),
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 24,
          height: 2.0,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  InlineSpan _buildVerseSpan(AcikKuranVerse verse) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextSpan(
      children: [
        TextSpan(
          text: '${verse.verse} ',
          recognizer: TapGestureRecognizer()..onTap = () => _showVerseOverlay(verse),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: InkWell(
            onTap: () => _showVerseOverlay(verse),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 1),
              ),
              child: Text(
                '${verse.verseNumber}',
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.primary,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ),
        ),
        const TextSpan(text: ' '),
      ],
    );
  }

  Widget _buildSurahHeader(AcikKuranSurah surah) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${surah.name} Suresi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontFamily: 'Manrope',
                ),
              ),
              Text(
                '${surah.verseCount} Ayet • Sayfa ${surah.pageNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          Text(
            surah.nameOriginal,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah(AcikKuranZero zero) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        zero.verse,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 24,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showVerseOverlay(AcikKuranVerse verse) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${verse.verseNumber}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
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
                            '${verse.surah.name} Suresi',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cüz ${verse.juzNumber} • Ayet ${verse.verseNumber}',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DailySharePreviewPage(
                              title: '${verse.surah.name} ${verse.verseNumber}',
                              content: verse.verse,
                              subtitle: verse.translation.text,
                              category: 'Verse',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.share_rounded, color: colorScheme.primary),
                      tooltip: 'Paylaş',
                    ),
                    StatefulBuilder(
                      builder: (context, setModalState) {
                        final isFavorited = _userFavorites.any((f) => f.externalId == "${verse.surah.id}:${verse.verseNumber}" && f.type == 1);
                        return IconButton(
                          onPressed: () async {
                            _toggleFavoriteHatim(verse);
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (mounted) {
                              setModalState(() {});
                            }
                          },
                          icon: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.red : colorScheme.primary,
                          ),
                          tooltip: 'Favorilere Ekle',
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1),
                ),
                Text(
                  verse.verse,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28,
                    height: 1.8,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 24),
                Text(
                  verse.transcription,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  verse.translation.text,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (verse.translation.footnotes != null && verse.translation.footnotes!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ...verse.translation.footnotes!.map((f) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[${f.number}] ',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            f.text,
                            style: textTheme.bodySmall?.copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(int page) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Sayfa yüklenemedi.',
              style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPagePicker() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedPage = _currentPage;
        return AlertDialog(
          title: const Text('Sayfaya Git'),
          content: TextField(
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Sayfa numarası (1-604)'),
            onChanged: (value) => selectedPage = int.tryParse(value) ?? _currentPage,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            TextButton(
              onPressed: () {
                if (selectedPage >= 1 && selectedPage <= 604) {
                  _pageController.jumpToPage(selectedPage - 1);
                }
                Navigator.pop(context);
              },
              child: const Text('Git'),
            ),
          ],
        );
      },
    );
  }

  void _showTOC() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTOCDrawer(),
    );
  }

  Widget _buildTOCDrawer() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fihrist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('last_hatim_page', 1);
                      if (mounted) {
                        setState(() => _currentPage = 1);
                        _pageController.jumpToPage(0);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.first_page, size: 20),
                    label: const Text('Başa Dön', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: const [Tab(text: 'Sureler'), Tab(text: 'Cüzler')],
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.outline,
              indicatorColor: colorScheme.primary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSurahList(),
                  _buildJuzList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      itemCount: _surahs.isNotEmpty ? _surahs.length : 114,
      itemBuilder: (context, index) {
        int id = index + 1;
        String name = _surahs.isNotEmpty ? _surahs[index].turkishName : 'Sure $id';
        int page = QuranConstants.surahToPage[id] ?? 1;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            child: Text('$id', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text('Sayfa $page', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          onTap: () {
            _pageController.jumpToPage(page - 1);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        int juz = index + 1;
        int page = QuranConstants.juzToPage[juz]!;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            child: Text('$juz', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ),
          title: Text('$juz. Cüz', style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text('Sayfa $page', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          onTap: () {
            _pageController.jumpToPage(page - 1);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
