import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import '../models/surah_model.dart';
import '../models/daily_verse_model.dart';
import '../services/quran_service.dart';
import '../services/audio_service.dart';
import '../services/user_progress_service.dart';
import '../services/favorite_service.dart';
import '../models/favorite_model.dart';
import '../utils/image_utils.dart';
import '../l10n/generated/app_localizations.dart';

class SurahDetailPage extends StatefulWidget {
  final SurahModel surah;
  final int? initialAyahNumber;

  const SurahDetailPage({
    super.key,
    required this.surah,
    this.initialAyahNumber,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> with SingleTickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  final AudioService _audioService = AudioService();
  final UserProgressService _userProgressService = UserProgressService();
  final FavoriteService _favoriteService = FavoriteService();
  final PageController _pageController = PageController();
  late AnimationController _rotationController;

  List<DailyVerseModel> _ayahs = [];
  List<Map<String, String>> _reciters = [];
  bool _isLoading = true;
  String _selectedLanguage = 'TR';
  Map<String, String>? _selectedReciter;
  List<FavoriteModel> _userFavorites = [];
  int _currentAyahIndex = 0;
  StreamSubscription? _currentIndexSub;
  StreamSubscription? _playingSub;
  late String _bgImage;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    ); // Do NOT repeat yet
    _bgImage = ImageUtils.getRandomDiniImage();
    _fetchData();
    _currentIndexSub = _audioService.player.currentIndexStream.listen((index) {
      if (index != null && mounted) {
        final sequenceLength = _audioService.player.sequence?.length ?? 0;
        if (sequenceLength == _ayahs.length) {
          if (_pageController.hasClients && _currentAyahIndex != index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });

    _playingSub = _audioService.player.playerStateStream.listen((state) {
      if (mounted) {
        final isActuallyPlaying = state.playing && state.processingState != ProcessingState.completed;
        setState(() => _isPlaying = isActuallyPlaying);
        if (isActuallyPlaying) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _currentIndexSub?.cancel();
    _playingSub?.cancel();
    _audioService.stop();
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (_ayahs.isNotEmpty && _currentAyahIndex < _ayahs.length) {
      final ayah = _ayahs[_currentAyahIndex];
      await _userProgressService.saveLastPosition(
        surahId: widget.surah.id,
        surahName: widget.surah.turkishName,
        ayahNumber: ayah.ayahNumber,
      );
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _bgImage = ImageUtils.getRandomDiniImage();
    });
    try {
      final results = await Future.wait([
        _quranService.getReciters(),
        _quranService.getAyahs(widget.surah.id, widget.surah.turkishName),
        _favoriteService.getFavorites(),
      ]);

      if (mounted) {
        setState(() {
          _reciters = results[0] as List<Map<String, String>>;
          if (_reciters.isNotEmpty) {
            _selectedReciter = _reciters.first;
          }
          _ayahs = results[1] as List<DailyVerseModel>;
          _userFavorites = results[2] as List<FavoriteModel>;
          _isLoading = false;

          // Jump to initial ayah if provided
          if (widget.initialAyahNumber != null && _ayahs.isNotEmpty) {
            final index = _ayahs.indexWhere((a) => a.ayahNumber == widget.initialAyahNumber);
            if (index != -1) {
              _currentAyahIndex = index;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(index);
                }
              });
            }
          }
          _saveProgress();
        });
      }
    } catch (e) {
      print('SurahDetailPage _fetchData Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleFavorite(DailyVerseModel ayah) async {
    final externalId = "${widget.surah.id}:${ayah.ayahNumber}";
    final existingIndex = _userFavorites.indexWhere((f) => f.externalId == externalId && f.type == 1);

    if (existingIndex != -1) {
      // Delete
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
      // Add
      final favorite = FavoriteModel(
        id: "", // Backend will generate
        type: 1, // Verse
        externalId: externalId,
        surahId: widget.surah.id,
        ayahNumber: ayah.ayahNumber,
        title: "${widget.surah.turkishName} ${ayah.ayahNumber}",
        contentArabic: ayah.arabic,
        contentText: ayah.translation,
        createdAt: DateTime.now(),
      );

      final success = await _favoriteService.addFavorite(favorite);
      if (success && mounted) {
        // Refresh favorites
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

  void _playKiraat() async {
    if (_selectedReciter == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.loadingRecitation)),
    );

    final urls = await _quranService.getFullSurahAudioUrls(
      _selectedReciter!['id']!,
      widget.surah.id,
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (urls.isNotEmpty) {
      _pageController.jumpToPage(0);
      await _audioService.playPlaylist(urls);
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.audioNotFound)),
      );
    }
  }

  void _playMeal() {
    // Meal audio is usually a single file for the whole surah from acikkuran
    String url;
    if (_selectedLanguage.toLowerCase() == "eng") {
      _selectedLanguage = "en";
      url =
          'https://audio.acikkuran.com/${_selectedLanguage.toLowerCase()}/00${widget.surah.id}.mp3';
    } else {
      url =
          'https://audio.acikkuran.com/${_selectedLanguage.toLowerCase()}/${widget.surah.id}.mp3';
    }
    _audioService.playUrl(url);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.translationStarted)));
  }

  void _playAyah(int index) async {
    if (_selectedReciter == null || index >= _ayahs.length) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir kâri seçin.')),
        );
      }
      return;
    }
    final ayah = _ayahs[index];
    
    print('SurahDetailPage: Getting path for Ayah ${ayah.ayahNumber} and reciter ${_selectedReciter!['id']}');
    
    final path = await _quranService.getAyahAudioPath(
      _selectedReciter!['id']!,
      widget.surah.id,
      ayah.ayahNumber,
    );
    
    print('SurahDetailPage: Ayah path received: $path');
    
    if (path != null && path.isNotEmpty) {
      _audioService.playFromApi(path);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.audioNotFound)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              const SizedBox(height: 100), // Height for fixed app bar
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(context),
                      const SizedBox(height: 32),
                      _buildHeroCard(context),
                      const SizedBox(height: 32),
                      _buildControlsRow(context),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                      const SizedBox(height: 16),
                      _buildMiniPlayer(context),
                      const SizedBox(height: 16),
                      _buildAyahSection(context),
                      const SizedBox(height: 120), // Bottom nav padding
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fixed App Bar
          Positioned(top: 0, left: 0, right: 0, child: _buildAppBar(context)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                AppLocalizations.of(context)!.surahDetail,
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.surah.turkishName,
          style: TextStyle(
            fontFamily: 'Noto Serif',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Icon(Icons.more_vert, color: colorScheme.outline),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.surah.turkishName,
                  style: const TextStyle(
                    fontFamily: 'Noto Serif',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.ayahCount(widget.surah.ayahCount).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                AppLocalizations.of(context)!.selectReciter.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _showReciterPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedReciter?['name'] ?? AppLocalizations.of(context)!.loading,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.expand_more, size: 16, color: colorScheme.onSurface),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [_buildLangBtn(context, 'TR'), _buildLangBtn(context, 'ENG')]),
        ),
      ],
    );
  }

  void _showReciterPicker() {
    if (_reciters.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.selectReciter,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reciters.length,
                  itemBuilder: (context, index) {
                    final r = _reciters[index];
                    return ListTile(
                      title: Text(r['name']!),
                      selected: _selectedReciter?['id'] == r['id'],
                      onTap: () {
                        setState(() => _selectedReciter = r);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangBtn(BuildContext context, String lang) {
    bool isSelected = _selectedLanguage == lang;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4)]
              : [],
        ),
        child: Text(
          lang,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? colorScheme.onSurface : colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _playKiraat,
            child: _buildActionBtn(context, AppLocalizations.of(context)!.listenRecitation, Icons.play_arrow, [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ], Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _playMeal,
            child: _buildActionBtn(context, AppLocalizations.of(context)!.listenTranslation, Icons.headphones, [
              colorScheme.surfaceVariant,
              colorScheme.surfaceVariant,
            ], colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    String label,
    IconData icon,
    List<Color> bgColors,
    Color textColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: bgColors[0] == colorScheme.primary
            ? [
                BoxShadow(
                  color: bgColors[0].withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<PlayerState>(
      stream: _audioService.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        if (playerState == null) return const SizedBox.shrink();
        final processingState = playerState.processingState;
        final playing = playerState.playing;

        if (processingState == ProcessingState.idle ||
            processingState == ProcessingState.completed) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                )
              else
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: colorScheme.primary),
                  onPressed: () {
                    if (playing) {
                      _audioService.pause();
                    } else {
                      _audioService.resume();
                    }
                  },
                ),
              const SizedBox(width: 8),
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _audioService.player.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: _audioService.player.durationStream,
                      builder: (context, durSnapshot) {
                        final duration = durSnapshot.data ?? Duration.zero;
                        double sliderValue = 0.0;
                        if (duration.inMilliseconds > 0) {
                          sliderValue = position.inMilliseconds / duration.inMilliseconds;
                        }
                        return LinearProgressIndicator(
                          value: sliderValue.clamp(0.0, 1.0),
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.outline),
                onPressed: () => _audioService.stop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAyahSection(BuildContext context) {
    if (_isLoading) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }
    if (_ayahs.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.ayahsNotLoaded,
              style: TextStyle(color: colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 420,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _ayahs.length,
              onPageChanged: (index) {
                setState(() => _currentAyahIndex = index);
                _saveProgress();
              },
              itemBuilder: (context, index) {
                final ayah = _ayahs[index];
                return _buildAyahCard(ayah, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCard(DailyVerseModel ayah, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = index == _currentAyahIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose a vibrant color for the rotating border
    final highlightColor = isDark ? colorScheme.secondary : colorScheme.primary;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isActive && _isPlaying) 
                        ? highlightColor.withValues(alpha: 0.1) 
                        : Colors.black.withAlpha(13), 
                    blurRadius: (isActive && _isPlaying) 
                        ? (10 + (10 * _rotationController.value)) 
                        : 10,
                    spreadRadius: (isActive && _isPlaying) ? 1 : 0,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Text(
                    ayah.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      height: 2.0,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Divider(height: 32),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Text(
                    ayah.translation,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      height: 1.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: i == (index % 3)
                              ? colorScheme.primary
                              : colorScheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleFavorite(ayah),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _userFavorites.any((f) => f.externalId == "${widget.surah.id}:${ayah.ayahNumber}" && f.type == 1)
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Icon(
                            _userFavorites.any((f) => f.externalId == "${widget.surah.id}:${ayah.ayahNumber}" && f.type == 1)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _userFavorites.any((f) => f.externalId == "${widget.surah.id}:${ayah.ayahNumber}" && f.type == 1)
                                ? Colors.red
                                : colorScheme.outline,
                            size: 16,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _playAyah(index),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.listenAyah,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.primary.withAlpha(51),
                                ),
                              ),
                              child: Icon(
                                Icons.play_circle,
                                color: colorScheme.primary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Ayah Counter at the bottom center
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '${index + 1} / ${_ayahs.length}',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        if (isActive && _isPlaying)
          Positioned(
            left: 4,
            right: 4,
            top: 8,
            bottom: 8,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: RotatingBorderPainter(
                    progress: _rotationController.value,
                    color: highlightColor,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class RotatingBorderPainter extends CustomPainter {
  final double progress;
  final Color color;

  RotatingBorderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;
    
    final pathMetric = pathMetrics.first;
    final totalLength = pathMetric.length;
    final segmentLength = totalLength * 0.25; // 25% of the border
    
    final start = totalLength * progress;
    final end = start + segmentLength;

    if (end <= totalLength) {
      canvas.drawPath(pathMetric.extractPath(start, end), paint);
    } else {
      // Wrap around
      canvas.drawPath(pathMetric.extractPath(start, totalLength), paint);
      canvas.drawPath(pathMetric.extractPath(0, end - totalLength), paint);
    }
  }

  @override
  bool shouldRepaint(RotatingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
