import 'package:flutter/cupertino.dart';

import 'aria_data.dart';
import 'aria_screen.dart';

class ComposerScreen extends StatelessWidget {
  final List<ComposerData> composers;
  final List<AriaSummary> allArias;

  const ComposerScreen({
    super.key,
    required this.composers,
    required this.allArias,
  });

  List<AriaSummary> _filterAriasForComposer(String composerName) {
    final lower = composerName.toLowerCase();

    return allArias.where((aria) {
      final c = aria.composer.toLowerCase();

      if (lower == 'verdi') return c.contains('verdi');
      if (lower == 'mozart') return c.contains('mozart');
      if (lower == 'rossini') return c.contains('rossini');
      if (lower == 'leoncavallo') return c.contains('leoncavallo');
      if (lower == 'gounod') return c.contains('gounod');
      if (lower == 'wagner') return c.contains('wagner');
      if (lower == 'giordano') return c.contains('giordano');
      if (lower == 'korngold') return c.contains('korngold');
      if (lower == 'donizetti') return c.contains('donizetti');

      return c.contains(lower);
    }).toList();
  }

  bool _isDark(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
  }

  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 980;
  }

  Color _pageBackground(BuildContext context) {
    return _isDark(context) ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  }

  Color _groupColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF1C1C1E) : CupertinoColors.white;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context) ? CupertinoColors.white : CupertinoColors.black;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context) ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
  }

  double _maxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1800) return 1600;
    if (width >= 1600) return 1460;
    if (width >= 1400) return 1320;
    if (width >= 1200) return 1180;
    if (width >= 980) return width - 48;
    return 760;
  }

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);

    return CupertinoPageScaffold(
      backgroundColor: _pageBackground(context),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(context)),
            child: wide
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: _introCard(context),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _composerCards(context, true),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                    children: [
                      _introCard(context),
                      const SizedBox(height: 24),
                      _composerCards(context, false),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _introCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _groupColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor(context)),
        boxShadow: _isDark(context)
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '작곡가',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.15,
              color: _primaryText(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '작곡가별로 아리아를 정리해서 볼 수 있어요.',
            style: TextStyle(
              fontSize: 15,
              color: _secondaryText(context),
              height: 1.4,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '총 ${composers.length}명의 작곡가',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _secondaryText(context),
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _composerCards(BuildContext context, bool wide) {
    const spacing = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cardWidth = wide
            ? (availableWidth - spacing) / 2
            : availableWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: composers.map((composer) {
            final arias = _filterAriasForComposer(composer.name);

            return SizedBox(
              width: cardWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: _groupColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor(context)),
                  boxShadow: _isDark(context)
                      ? null
                      : const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            composer.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.15,
                              color: _primaryText(context),
                            ),
                          ),
                          if (composer.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              composer.subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: _secondaryText(context),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _isDark(context)
                                  ? const Color(0xFF2C2C2E)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${arias.length}곡',
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryText(context),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (arias.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: Text(
                          '등록된 아리아가 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: _secondaryText(context),
                          ),
                        ),
                      )
                    else
                      ...List.generate(arias.length, (index) {
                        final aria = arias[index];

                        return Column(
                          children: [
                            _divider(context),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => AriaScreen(aria: aria),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 15,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            aria.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: _primaryText(context),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            aria.composer,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _secondaryText(context),
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      CupertinoIcons.chevron_forward,
                                      size: 18,
                                      color: _secondaryText(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 18),
      height: 0.5,
      color: _isDark(context)
          ? const Color(0xFF3A3A3C)
          : const Color(0xFFC6C6C8),
    );
  }
}
