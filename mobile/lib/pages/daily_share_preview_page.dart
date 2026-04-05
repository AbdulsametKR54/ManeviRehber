import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../l10n/generated/app_localizations.dart';

class DailySharePreviewPage extends StatefulWidget {
  final String title;
  final String content;
  final String? subtitle;
  final String? category; // Added for content type from backend

  const DailySharePreviewPage({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    this.category,
  });

  @override
  State<DailySharePreviewPage> createState() => _DailySharePreviewPageState();
}

class _DailySharePreviewPageState extends State<DailySharePreviewPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;

  final List<String> _backgrounds = [
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?q=80&w=1080&auto=format&fit=crop', // Nature Hills
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=1080&auto=format&fit=crop', // Forest
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=1080&auto=format&fit=crop', // Foggy Mountain
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1080&auto=format&fit=crop', // Beach
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1080&auto=format&fit=crop', // Mountain peaks
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1080&auto=format&fit=crop', // Yosemite
    'https://images.unsplash.com/photo-1434725039720-abb26e2508ca?q=80&w=1080&auto=format&fit=crop', // Fields
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=1080&auto=format&fit=crop', // Lake
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=1080&auto=format&fit=crop', // Green Valley
    'https://images.unsplash.com/photo-1493246507139-91e8bef99c02?q=80&w=1080&auto=format&fit=crop', // Abstract water
    'https://images.unsplash.com/photo-1532274402911-5a3b027c55b9?q=80&w=1080&auto=format&fit=crop', // Lavender fields
    'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?q=80&w=1080&auto=format&fit=crop', // Macro nature
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=1080&auto=format&fit=crop', // Travel mountain
    'https://images.unsplash.com/photo-1500627768582-b7d83e201b1a?q=80&w=1080&auto=format&fit=crop', // Spiritual landscape
    'https://images.unsplash.com/photo-1547471080-7cc20320141b?q=80&w=1080&auto=format&fit=crop', // Desert calmness
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=1080&auto=format&fit=crop', // Old tree
    'https://images.unsplash.com/photo-1515150144380-bca9f1650ed9?q=80&w=1080&auto=format&fit=crop', // Sunlight through trees
    'https://images.unsplash.com/photo-1444464666168-49d633b867ad?q=80&w=1080&auto=format&fit=crop', // Birds in forest
    'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?q=80&w=1080&auto=format&fit=crop', // Cloudy horizon
    'https://images.unsplash.com/photo-1422490305611-2f70177cc9b2?q=80&w=1080&auto=format&fit=crop', // Snowy peace
  ];

  int _selectedBgIndex = 0;
  bool _useSidePanelLayout = true;

  @override
  void initState() {
    super.initState();
    // Auto-detect: if content is long (> 150 chars), suggest centered layout
    if (widget.content.length > 150) {
      _useSidePanelLayout = false;
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Bekleme ekleyelim, render objesinin hazır olduğundan emin olalım
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception("RepaintBoundary found null");
      }

      // 1080x1920 hedef olduğu için yüksek çözünürlük için pixelRatio kullanıyoruz
      // Not: Normal boyutu 1080x1920 olan bir container olduğu için ratio 1 yeterli.
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/daily_content_share.png');
      await file.writeAsBytes(pngBytes);

      final xFile = XFile(file.path);
      
      // Hemen loaderı kapatalım, kullanıcı paylaşım ekranından dönene kadar buton kitlenmesin
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }

      await Share.shareXFiles([xFile]);

    } catch (e) {
      debugPrint('Error sharing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  String _getLocalizedCategory(String? category, AppLocalizations l10n) {
    if (category == null) return '';
    
    // Map backend type names (Verse, Hadith, Quote, Prayer) to localized strings
    final cat = category.toLowerCase();
    if (cat.contains('verse') || cat.contains('ayah')) return l10n.contentVerse;
    if (cat.contains('hadith')) return l10n.contentHadith;
    if (cat.contains('quote') || cat.contains('word')) return l10n.contentQuote;
    if (cat.contains('prayer') || cat.contains('dua')) return l10n.contentPrayer;
    
    return category; // Fallback
  }

  String _getLocalizedSubtitle(String? subtitle, AppLocalizations l10n) {
    if (subtitle == null) return '';
    final sub = subtitle.toLowerCase();
    if (sub == 'quote' || sub == 'word' || sub == 'spiritual') return l10n.contentQuote;
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now()).toUpperCase();
    final localizedCategory = _getLocalizedCategory(widget.category, l10n);
    final localizedSubtitle = _getLocalizedSubtitle(widget.subtitle, l10n);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          l10n.sharePreview,
          style: const TextStyle(fontFamily: 'Manrope', color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: AspectRatio(
                  aspectRatio: 1080 / 1920,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: SizedBox(
                            width: 1080,
                            height: 1920,
                            child: Stack(
                              children: [
                                // Background Image
                                Positioned.fill(
                                  child: Image.network(
                                    _backgrounds[_selectedBgIndex],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[900],
                                      child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 100),
                                    ),
                                  ),
                                ),
                                _useSidePanelLayout 
                                  ? _buildSidePanelLayout(context, dateStr, localizedCategory, localizedSubtitle)
                                  : _buildCenteredLayout(context, dateStr, localizedCategory, localizedSubtitle),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.selectBackground,
                        style: TextStyle(
                          fontFamily: 'Manrope', 
                          fontSize: 13, 
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).colorScheme.outline
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => _useSidePanelLayout = !_useSidePanelLayout),
                        icon: Icon(_useSidePanelLayout ? Icons.view_sidebar : Icons.view_agenda, size: 16),
                        label: Text(
                          _useSidePanelLayout ? "Split View" : "Centered View", 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Background Thumbnail Selector
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _backgrounds.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedBgIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedBgIndex = index),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, 
                                width: 3
                              ),
                              image: DecorationImage(
                                image: NetworkImage(_backgrounds[index]), 
                                fit: BoxFit.cover
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareImage,
                      icon: _isSharing 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.share_rounded),
                      label: Text(
                        _isSharing ? l10n.sharing : l10n.shareAsImage, 
                        style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanelLayout(BuildContext context, String dateStr, String localizedCategory, String localizedSubtitle) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 1080 * 0.35,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withValues(alpha: 0.98),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, dateStr, localizedCategory, 20, 30),
                const SizedBox(height: 30),
                _buildDivider(context),
                const SizedBox(height: 60),

                Expanded(
                  child: _buildMainContent(context, widget.content, localizedSubtitle, 48, 24, true),
                ),

                const SizedBox(height: 40),
                _buildFooter(context, 100, 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredLayout(BuildContext context, String dateStr, String localizedCategory, String localizedSubtitle) {
    return Positioned.fill(
      child: Center(
        child: Container(
          width: 1080 * 0.85,
          margin: const EdgeInsets.symmetric(vertical: 120),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.white.withValues(alpha: 0.95),
                padding: const EdgeInsets.all(80),
                child: Column(
                  children: [
                    _buildHeader(context, dateStr, localizedCategory, 22, 36, isCentered: true),
                    const SizedBox(height: 40),
                    _buildDivider(context, isCentered: true),
                    const SizedBox(height: 80),
                    
                    Expanded(
                      child: _buildMainContent(context, widget.content, localizedSubtitle, 52, 28, false, isCentered: true),
                    ),

                    const SizedBox(height: 60),
                    _buildFooter(context, 120, 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String dateStr, String localizedCategory, double dateSize, double catSize, {bool isCentered = false}) {
    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: dateSize,
            letterSpacing: 4,
            color: const Color(0xFFcbd5e1),
          ),
        ),
        if (localizedCategory.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            localizedCategory.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w900,
              fontSize: catSize,
              letterSpacing: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider(BuildContext context, {bool isCentered = false}) {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, String content, String localizedSubtitle, double fontSize, double subSize, bool useOverlayQuote, {bool isCentered = false}) {
    double finalFontSize = fontSize;
    if (content.length > 250) finalFontSize *= 0.85;
    if (content.length > 500) finalFontSize *= 0.75;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (useOverlayQuote)
          Positioned(
            top: -90,
            left: -40,
            child: Opacity(
              opacity: 0.9,
              child: Text(
                '“',
                style: TextStyle(
                  fontFamily: 'Noto Serif',
                  fontSize: 240,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  height: 1.0,
                ),
              ),
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontFamily: 'Noto Serif',
                fontSize: finalFontSize,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0f172a),
                fontStyle: FontStyle.italic,
              ),
              softWrap: true,
            ),
            if (localizedSubtitle.isNotEmpty) ...[
              const SizedBox(height: 50),
              Text(
                localizedSubtitle,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: subSize,
                  letterSpacing: 1.5,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, double logoSize, double nameSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              'assets/logo/Manevi_Rehber-Logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.auto_awesome, color: Colors.teal, size: logoSize * 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manevi Rehber',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w900,
              fontSize: nameSize,
              letterSpacing: 0.8,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
