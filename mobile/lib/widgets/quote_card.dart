import 'package:flutter/material.dart';
import '../models/daily_content_model.dart';
import '../l10n/generated/app_localizations.dart';
import '../pages/daily_share_preview_page.dart';

class QuoteCard extends StatelessWidget {
  final DailyContentModel? model;
  final bool isLoading;

  const QuoteCard({
    super.key,
    this.model,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        height: 180,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final content = model?.content ?? AppLocalizations.of(context)!.contentLoadError;
    final title = model?.title ?? AppLocalizations.of(context)!.unknown;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background large quote icon
          Positioned(
            right: -24,
            top: -24,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.format_quote_rounded,
                size: 150, // very large 8xl
                color: colorScheme.onSurface,
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.dailyQuote.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: colorScheme.outline, // stone-400 equivalent
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '"$content"',
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.625, // leading-relaxed
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.outline, // stone-500 equivalent
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (model != null)
                        IconButton(
                          icon: Icon(Icons.share_rounded, color: colorScheme.primary, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DailySharePreviewPage(
                                  title: model!.title,
                                  content: model!.content,
                                  subtitle: model!.title, // Use author/title as subtitle
                                  category: model!.typeName,
                                ),
                              ),
                            );
                          },
                          tooltip: AppLocalizations.of(context)!.share,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
