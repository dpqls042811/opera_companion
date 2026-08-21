import 'package:flutter/cupertino.dart';

import 'aria_data.dart';
import 'aria_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<AriaSummary> arias;

  const SearchScreen({
    super.key,
    required this.arias,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Map<String, List<AriaSummary>> _groupByComposer(List<AriaSummary> arias) {
    final map = <String, List<AriaSummary>>{};
    for (final aria in arias) {
      map.putIfAbsent(aria.composer, () => []);
      map[aria.composer]!.add(aria);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    final hasQuery = trimmed.isNotEmpty;

    final filtered = hasQuery
        ? widget.arias.where((aria) {
            final q = trimmed.toLowerCase();
            return aria.title.toLowerCase().contains(q) ||
                aria.composer.toLowerCase().contains(q) ||
                aria.id.toLowerCase().contains(q);
          }).toList()
        : <AriaSummary>[];

    final grouped = _groupByComposer(filtered);
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
                          width: 340,
                          child: _searchPanel(context),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _resultPanel(context, hasQuery, grouped),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                    children: [
                      _searchPanel(context),
                      const SizedBox(height: 20),
                      _resultPanel(context, hasQuery, grouped),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _searchPanel(BuildContext context) {
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
            '검색',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.15,
              color: _primaryText(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '아리아 제목, 작곡가 이름으로 검색하세요.',
            style: TextStyle(
              fontSize: 15,
              color: _secondaryText(context),
              height: 1.4,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoSearchTextField(
            controller: _controller,
            placeholder: '아리아 제목, 작곡가 검색',
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _resultPanel(
    BuildContext context,
    bool hasQuery,
    Map<String, List<AriaSummary>> grouped,
  ) {
    if (!hasQuery) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
          children: [
            Icon(
              CupertinoIcons.search_circle_fill,
              size: 54,
              color: CupertinoColors.systemPink.withOpacity(0.8),
            ),
            const SizedBox(height: 14),
            Text(
              '아리아를 검색해보세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
                color: _primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '검색어를 입력하면 결과가 여기 나타나요.',
              style: TextStyle(
                fontSize: 15,
                color: _secondaryText(context),
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (grouped.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 44,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 14),
            Text(
              '검색 결과가 없습니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
                color: _primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 제목이나 작곡가 이름으로 다시 검색해보세요.',
              style: TextStyle(
                fontSize: 15,
                color: _secondaryText(context),
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final composerNames = grouped.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(
            '작곡가별 검색 결과',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              color: _secondaryText(context),
            ),
          ),
        ),
        ...composerNames.map((composer) {
          final items = grouped[composer]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Text(
                      composer,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.15,
                        color: _primaryText(context),
                      ),
                    ),
                  ),
                  ...List.generate(items.length, (index) {
                    final aria = items[index];
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
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
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
        }),
      ],
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
