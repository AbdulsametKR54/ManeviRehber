import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/favorite_model.dart';
import '../l10n/generated/app_localizations.dart';
import 'surah_detail_page.dart';
import '../services/quran_service.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final QuranService _quranService = QuranService();
  
  List<FavoriteModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favs = await _favoriteService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _isLoading = false;
      });
    }
  }

  void _deleteFavorite(String id) async {
    final success = await _favoriteService.deleteFavorite(id);
    if (success && mounted) {
      setState(() {
        _favorites.removeWhere((f) => f.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorilerden kaldırıldı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.favorites, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState(colorScheme, l10n)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final fav = _favorites[index];
                    return _buildFavoriteCard(fav, colorScheme);
                  },
                ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Henüz favori eklenmemiş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.outline,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteModel fav, ColorScheme colorScheme) {
    IconData icon;
    String typeLabel;
    
    switch (fav.type) {
      case 1:
        icon = Icons.menu_book_rounded;
        typeLabel = 'AYET';
        break;
      case 2:
        icon = Icons.message_rounded;
        typeLabel = 'HADİS';
        break;
      case 3:
        icon = Icons.format_quote_rounded;
        typeLabel = 'SÖZ';
        break;
      case 4:
        icon = Icons.front_hand_rounded;
        typeLabel = 'DUA';
        break;
      default:
        icon = Icons.favorite;
        typeLabel = 'FAVORİ';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onFavoriteTap(fav),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 16, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.withValues(alpha: 0.7),
                        onPressed: () => _deleteFavorite(fav.id),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (fav.contentArabic != null && fav.contentArabic!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        fav.contentArabic ?? '',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    fav.contentText ?? '',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fav.title ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onFavoriteTap(FavoriteModel fav) async {
    if (fav.type == 1 && fav.surahId != null) {
      // Verse: Navigate to Surah Detail
      final surahs = await _quranService.getSurahs();
      final surah = surahs.firstWhere((s) => s.id == fav.surahId, orElse: () => surahs.first);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(
              surah: surah,
              initialAyahNumber: fav.ayahNumber,
            ),
          ),
        );
      }
    } else {
      // Other contents: Show in a dialog for now or detail page if exists
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(fav.title ?? ''),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fav.contentArabic != null)
                  Text(
                    fav.contentArabic ?? '',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Amiri', fontSize: 24),
                  ),
                const SizedBox(height: 16),
                Text(fav.contentText ?? ''),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
          ],
        ),
      );
    }
  }
}
