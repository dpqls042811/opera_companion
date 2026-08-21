import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aria_data.dart';
import 'aria_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<AriaSummary> arias;
  final List<ComposerData> composers;

  const HomeScreen({
    super.key,
    required this.arias,
    required this.composers,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _recentAriasKey = 'recent_arias';
  static const String _lastOpenedAriaKey = 'last_opened_aria';

  final List<AriaSummary> _recentArias = [];
  AriaSummary? _lastOpenedAria;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  bool _isDark(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
  }

  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 960;
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

  Color _accentText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFD7E6FF)
        : const Color(0xFF245EA9);
  }

  Color _heroBackground(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF111214)
        : const Color(0xFFF7F9FC);
  }

  Color _iconSoftBackground(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFEAF2FF);
  }

  Color _primaryButtonBackground(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF2C2C2E)
        : const Color(0xFF245EA9);
  }

  Color _primaryButtonText(BuildContext context) {
    return CupertinoColors.white;
  }

  double _maxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1800) return 1600;
    if (width >= 1600) return 1460;
    if (width >= 1400) return 1320;
    if (width >= 1200) return 1180;
    if (width >= 960) return width - 48;
    return 760;
  }

  Map<String, dynamic> _ariaToJson(AriaSummary aria) {
    return {
      'id': aria.id,
      'title': aria.title,
      'composer': aria.composer,
      'languageCode': aria.languageCode,
    };
  }

  AriaSummary? _ariaFromJson(Map<String, dynamic> json) {
    try {
      return AriaSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        composer: json['composer'] as String,
        languageCode: (json['languageCode'] ?? 'de') as String,
      );
    } catch (_) {
      return null;
    }
  }

  AriaSummary? _findMatchingAria(String id) {
    try {
      return widget.arias.firstWhere((aria) => aria.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final recentStrings = prefs.getStringList(_recentAriasKey) ?? [];
    final lastOpenedString = prefs.getString(_lastOpenedAriaKey);

    final List<AriaSummary> loadedRecent = [];

    for (final item in recentStrings) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        final stored = _ariaFromJson(decoded);
        if (stored == null) continue;

        final matched = _findMatchingAria(stored.id);
        loadedRecent.add(matched ?? stored);
      } catch (_) {
        // ignore broken item
      }
    }

    AriaSummary? loadedLastOpened;
    if (lastOpenedString != null) {
      try {
        final decoded = jsonDecode(lastOpenedString) as Map<String, dynamic>;
        final stored = _ariaFromJson(decoded);
        if (stored != null) {
          loadedLastOpened = _findMatchingAria(stored.id) ?? stored;
        }
      } catch (_) {
        // ignore broken item
      }
    }

    if (!mounted) return;

    setState(() {
      _recentArias
        ..clear()
        ..addAll(loadedRecent);
      _lastOpenedAria = loadedLastOpened;
      _isLoadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final recentStrings = _recentArias
        .map((aria) => jsonEncode(_ariaToJson(aria)))
        .toList();

    await prefs.setStringList(_recentAriasKey, recentStrings);

    if (_lastOpenedAria != null) {
      await prefs.setString(
        _lastOpenedAriaKey,
        jsonEncode(_ariaToJson(_lastOpenedAria!)),
      );
    } else {
      await prefs.remove(_lastOpenedAriaKey);
    }
  }

  void _registerRecent(AriaSummary aria) {
    _recentArias.removeWhere((item) => item.id == aria.id);
    _recentArias.insert(0, aria);

    if (_recentArias.length > 6) {
      _recentArias.removeRange(6, _recentArias.length);
    }

    _lastOpenedAria = aria;
    _saveHistory();
  }

  void _openAria(BuildContext context, AriaSummary aria) {
    setState(() {
      _registerRecent(aria);
    });

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => AriaScreen(aria: aria),
      ),
    );
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
            child: _isLoadingHistory
                ? const Center(
                    child: CupertinoActivityIndicator(radius: 16),
                  )
                : wide
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 340,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _header(context),
                                  const SizedBox(height: 24),
                                  _sectionTitle(context, '이어서 보기'),
                                  _continueCard(context),
                                  const SizedBox(height: 20),
                                  _sectionTitle(context, '최근 본 아리아'),
                                  _recentAriasCard(context),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle(context, '전체 아리아'),
                                  const SizedBox(height: 2),
                                  Expanded(
                                    child: _ariaListScrollable(
                                      context,
                                      widget.arias,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                        children: [
                          _header(context),
                          const SizedBox(height: 20),
                          _sectionTitle(context, '이어서 보기'),
                          _continueCard(context),
                          const SizedBox(height: 20),
                          _sectionTitle(context, '최근 본 아리아'),
                          _recentAriasCard(context),
                          const SizedBox(height: 20),
                          _sectionTitle(context, '전체 아리아'),
                          _ariaListCard(context, widget.arias),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '규니의 아리아 노트♥',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.15,
              color: _primaryText(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '가사, 뜻, 발음까지 한곳에 정리한 규니만의 노트',
            softWrap: true,
            maxLines: 2,
            style: TextStyle(
              fontSize: 16,
              color: _secondaryText(context),
              height: 1.45,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
          color: _secondaryText(context),
        ),
      ),
    );
  }

  Widget _continueCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _heroBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor(context)),
        boxShadow: _isDark(context)
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: _lastOpenedAria == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아직 연 아리아가 없어요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '오른쪽 전체 아리아에서 한 곡을 열어보면 여기서 바로 이어서 볼 수 있어요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryText(context),
                    height: 1.45,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lastOpenedAria!.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _primaryText(context),
                    height: 1.25,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _lastOpenedAria!.composer,
                  style: TextStyle(
                    fontSize: 15,
                    color: _secondaryText(context),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 14),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: _primaryButtonBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => _openAria(context, _lastOpenedAria!),
                  child: Text(
                    '다시 열기',
                    style: TextStyle(
                      color: _primaryButtonText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _recentAriasCard(BuildContext context) {
    if (_recentArias.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
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
        child: Text(
          '최근 본 아리아가 아직 없어요.',
          style: TextStyle(
            fontSize: 14,
            color: _secondaryText(context),
            height: 1.45,
          ),
        ),
      );
    }

    return Container(
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
        children: List.generate(_recentArias.length, (index) {
          final aria = _recentArias[index];
          return Column(
            children: [
              _compactAriaCell(context, aria),
              if (index != _recentArias.length - 1) _divider(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _compactAriaCell(BuildContext context, AriaSummary aria) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _openAria(context, aria),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _iconSoftBackground(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                CupertinoIcons.clock,
                size: 18,
                color: _accentText(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aria.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: _primaryText(context),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aria.composer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: _secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ariaListScrollable(BuildContext context, List<AriaSummary> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Text(
          '등록된 아리아가 없어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: _secondaryText(context),
          ),
        ),
      );
    }

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CupertinoScrollbar(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, __) => _divider(context),
            itemBuilder: (context, index) {
              final aria = items[index];
              return _ariaCell(context, aria);
            },
          ),
        ),
      ),
    );
  }

  Widget _ariaListCard(BuildContext context, List<AriaSummary> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Text(
          '등록된 아리아가 없어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: _secondaryText(context),
          ),
        ),
      );
    }

    return Container(
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
        children: List.generate(items.length, (index) {
          final aria = items[index];
          return Column(
            children: [
              _ariaCell(context, aria),
              if (index != items.length - 1) _divider(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _ariaCell(BuildContext context, AriaSummary aria) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _openAria(context, aria),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 6),
                  Text(
                    aria.composer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: _secondaryText(context),
                      letterSpacing: 0.15,
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
