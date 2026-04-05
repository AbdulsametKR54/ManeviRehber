import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/zikr_models.dart';
import '../services/zikr_service.dart';

class ZikirmatikPage extends StatefulWidget {
  const ZikirmatikPage({super.key});

  @override
  State<ZikirmatikPage> createState() => _ZikirmatikPageState();
}

class _ZikirmatikPageState extends State<ZikirmatikPage> {
  int _count = 0;
  final int _target = 9999;
  ZikrPhrase _selectedPhrase = ZikrPhrase.subhanallah;
  final ZikrService _zikrService = ZikrService();
  List<ZikrDailySummary>? _summary;
  bool _isLoadingSummary = false;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _isLoadingSummary = true);
    final summary = await _zikrService.getDailySummary();
    if (mounted) {
      setState(() {
        _summary = summary;
        _isLoadingSummary = false;
      });
    }
  }

  String _getZikrLabel(ZikrPhrase phrase, AppLocalizations l10n) {
    switch (phrase) {
      case ZikrPhrase.subhanallah: return l10n.subhanallah;
      case ZikrPhrase.elhamdulillah: return l10n.alhamdulillah;
      case ZikrPhrase.allahuEkber: return l10n.allahuAkbar;
      case ZikrPhrase.laIlaheIllallah: return l10n.laIlaheIllallah;
      case ZikrPhrase.estagfirullah: return l10n.estagfirullah;
    }
  }

  void _increment() {
    setState(() {
      if (_count < _target) {
        _count++;
      }
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  Future<void> _save() async {
    final success = await _zikrService.saveZikr(_selectedPhrase, _count, DateTime.now());
    if (mounted) {
      if (success) {
        _reset();
        _fetchSummary();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? AppLocalizations.of(context)!.zikrSaved 
            : AppLocalizations.of(context)!.contentLoadError),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                l10n.appName,
                style: TextStyle(
                  fontFamily: 'Noto Serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                  color: colorScheme.primary,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background abstract glows
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Icon(Icons.auto_awesome, size: 200, color: Colors.black),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -20,
            child: IgnorePointer(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 80,
                      spreadRadius: 80,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Header Text
                  Text(
                    l10n.zikirmatik,
                    style: textTheme.headlineLarge?.copyWith(
                      fontFamily: 'Noto Serif',
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.zikirmatikSub,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Manrope',
                      letterSpacing: 0.5,
                      color: colorScheme.outline,
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                   Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$_count',
                        style: textTheme.displayLarge?.copyWith(
                          fontFamily: 'Noto Serif',
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PopupMenuButton<ZikrPhrase>(
                    initialValue: _selectedPhrase,
                    onSelected: (ZikrPhrase phrase) {
                      setState(() => _selectedPhrase = phrase);
                    },
                    itemBuilder: (context) => ZikrPhrase.values.map((phrase) {
                      return PopupMenuItem<ZikrPhrase>(
                        value: phrase,
                        child: Text(_getZikrLabel(phrase, l10n)),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getZikrLabel(_selectedPhrase, l10n).toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Interaction Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Reset Button
                        GestureDetector(
                          onTap: () => _reset(),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.refresh, color: colorScheme.outline, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.reset,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Main Pulse Button
                        GestureDetector(
                          onTap: () => _increment(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '+1',
                                style: TextStyle(
                                  fontFamily: 'Noto Serif',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Save Button
                        GestureDetector(
                          onTap: () => _save(),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.bookmark, color: colorScheme.outline, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.save.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Goal Indicator
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.goalProgress,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: colorScheme.primary,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Noto Serif',
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                children: [
                                  TextSpan(text: '$_count '),
                                  TextSpan(
                                    text: '/ $_target',
                                    style: TextStyle(
                                      fontFamily: 'Noto Serif',
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              width: 280 * (_count / _target).clamp(0.0, 1.0),
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSummaryTable(colorScheme, textTheme, l10n),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, 
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, ModalRoute.withName('/home'));
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/quran');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/prayer');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }

  Widget _buildSummaryTable(ColorScheme colorScheme, TextTheme textTheme, AppLocalizations l10n) {
    if (_isLoadingSummary) {
      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
    }

    final hasSummary = _summary != null && _summary!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Geçmiş Zikirlerim",
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasSummary)
                IconButton(
                  icon: Icon(Icons.share, color: colorScheme.primary, size: 20),
                  onPressed: _showShareActionSheet,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasSummary)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Henüz zikir kaydınız bulunmamaktadır.",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
              },
              children: [
                // Header Row
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        l10n.date.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "KELİME",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "TOPLAM",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                for (var s in _summary!)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          "${s.date.day}.${s.date.month}.${s.date.year}",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          _getZikrLabel(ZikrPhraseExtension.fromKey(s.phrase), l10n),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          "${s.total}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Noto Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _showShareActionSheet() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Zikir Günlüğü Paylaşım Görseli Hazırlanıyor...")),
    );
    
    // Antigravity Prompt - Zikir Günlüğü Paylaşım Tasarımı
  }
}
