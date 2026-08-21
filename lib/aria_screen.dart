import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Curves;

import 'app_settings.dart';
import 'aria_data.dart';
import 'data/load_all_arias.dart';
import 'pronunciation_service.dart';

class AriaScreen extends StatefulWidget {
  final AriaSummary aria;

  const AriaScreen({
    super.key,
    required this.aria,
  });

  @override
  State<AriaScreen> createState() => _AriaScreenState();
}

class _AriaScreenState extends State<AriaScreen>
    with TickerProviderStateMixin {
  late Future<AriaData> future;
  final PronunciationService _pronunciationService = PronunciationService();

  int? selectedLineIndex;
  String? _speakingWord;

  @override
  void initState() {
    super.initState();
    future = AllAriasRepository.loadAriaDetail(widget.aria.id);
  }

  bool _isDark(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
  }

  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 980;
  }

  Color _pageBackground(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
  }

  Color _groupColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.white;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context) ? CupertinoColors.white : CupertinoColors.black;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6E6E73);
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);
  }

  Color _selectedColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF2A2A2D)
        : const Color(0xFFF4F8FC);
  }

  Color _selectedBorderColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF4A4A4D)
        : const Color(0xFFD7E5F2);
  }

  Color _accentColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF8DBBFF)
        : const Color(0xFF2B79C2);
  }

  Color _speakingCardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF243244)
        : const Color(0xFFEAF3FF);
  }

  Color _speakingBorderColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF4B6B8F)
        : const Color(0xFFB9D3F0);
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

  String _languageLabel(String code) {
    switch (code) {
      case 'de':
        return '독일어';
      case 'it':
        return '이탈리아어';
      default:
        return code;
    }
  }

  Future<void> _speakWord(String word, String languageCode) async {
    setState(() {
      _speakingWord = word;
    });

    await _pronunciationService.playPronunciation(word, languageCode);

    if (!mounted) return;

    setState(() {
      _speakingWord = null;
    });
  }

  @override
  void dispose() {
    _pronunciationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return CupertinoPageScaffold(
          backgroundColor: _pageBackground(context),
          navigationBar: CupertinoNavigationBar(
            middle: FutureBuilder<AriaData>(
              future: future,
              builder: (context, snapshot) {
                final title = snapshot.data?.title ?? '곡';
                return Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    letterSpacing: 0.15,
                    color: _primaryText(context),
                  ),
                );
              },
            ),
            previousPageTitle: '뒤로',
          ),
          child: SafeArea(
            child: FutureBuilder<AriaData>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CupertinoActivityIndicator(radius: 16),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _groupColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _borderColor(context)),
                        ),
                        child: Text(
                          '상세 로드 실패\n\n${snapshot.error}',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: _primaryText(context),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                final wide = _isWide(context);

                return Center(
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
                                  child: _infoPanel(context, data),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _linesPanel(context, data),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                            children: [
                              _infoPanel(context, data),
                              const SizedBox(height: 20),
                              _linesPanel(context, data),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _infoPanel(BuildContext context, AriaData data) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              height: 1.25,
              color: _primaryText(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.composer,
            style: TextStyle(
              fontSize: 17,
              color: _secondaryText(context),
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _languageLabel(data.languageCode),
            style: TextStyle(
              fontSize: 14,
              color: _accentColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linesPanel(BuildContext context, AriaData data) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final lines = data.lines;

    if (!isWide) {
      return Column(
        children: List.generate(lines.length, (index) {
          final line = lines[index];
          final selected = selectedLineIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _lineCard(
              context,
              line: line,
              index: index,
              selected: selected,
              languageCode: data.languageCode,
            ),
          );
        }),
      );
    }

    return Column(
      children: List.generate((lines.length / 2).ceil(), (rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;

        final leftLine = lines[leftIndex];
        final rightLine = rightIndex < lines.length ? lines[rightIndex] : null;

        final leftSelected = selectedLineIndex == leftIndex;
        final rightSelected = selectedLineIndex == rightIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _lineCard(
                  context,
                  line: leftLine,
                  index: leftIndex,
                  selected: leftSelected,
                  languageCode: data.languageCode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: rightLine != null
                    ? _lineCard(
                        context,
                        line: rightLine,
                        index: rightIndex,
                        selected: rightSelected,
                        languageCode: data.languageCode,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _lineCard(
    BuildContext context, {
    required AriaLineData line,
    required int index,
    required bool selected,
    required String languageCode,
  }) {
    final hasMeaning = line.meaning.trim().isNotEmpty;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          selectedLineIndex = selected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        decoration: BoxDecoration(
          color: selected ? _selectedColor(context) : _groupColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _selectedBorderColor(context)
                : _borderColor(context),
            width: 1,
          ),
          boxShadow: _isDark(context)
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.text,
                  style: TextStyle(
                    fontSize: appSettings.lyricFontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    letterSpacing: 0.2,
                    color: _primaryText(context),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedCrossFade(
                  firstCurve: Curves.easeOutCubic,
                  secondCurve: Curves.easeOutCubic,
                  sizeCurve: Curves.easeOutCubic,
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: selected
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: hasMeaning
                      ? Text(
                          line.meaning,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.15,
                            color: _secondaryText(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                  secondChild: _expandedLineDetail(
                    context,
                    line: line,
                    languageCode: languageCode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _expandedLineDetail(
    BuildContext context, {
    required AriaLineData line,
    required String languageCode,
  }) {
    final items = _buildAnalysisItems(line);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (line.meaning.trim().isNotEmpty) ...[
          _sectionLabel(context, '해석'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _groupColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor(context)),
            ),
            child: Text(
              line.meaning,
              style: TextStyle(
                fontSize: 16,
                height: 1.55,
                letterSpacing: 0.12,
                color: _primaryText(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        if (items.isNotEmpty) ...[
          const SizedBox(height: 18),
          _sectionLabel(context, '단어 분석'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: items.map((item) {
              return _wordCard(
                context,
                word: item.word,
                ipa: item.ipa,
                meaning: item.meaning,
                languageCode: languageCode,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
          color: _accentColor(context),
        ),
      ),
    );
  }

  Widget _wordCard(
    BuildContext context, {
    required String word,
    String? ipa,
    String? meaning,
    required String languageCode,
  }) {
    final hasIpa = ipa != null && ipa.trim().isNotEmpty;
    final hasMeaning = meaning != null && meaning.trim().isNotEmpty;
    final isSpeaking = _speakingWord == word;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: () => _speakWord(word, languageCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 220,
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: isSpeaking ? _speakingCardColor(context) : _groupColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSpeaking
                ? _speakingBorderColor(context)
                : _borderColor(context),
          ),
          boxShadow: _isDark(context)
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    word,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primaryText(context),
                      height: 1.3,
                    ),
                  ),
                ),
                if (isSpeaking) ...[
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.speaker_2_fill,
                    size: 16,
                    color: _accentColor(context),
                  ),
                ],
              ],
            ),
            if (hasIpa) ...[
              const SizedBox(height: 5),
              Text(
                '[${ipa!.trim()}]',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: _secondaryText(context),
                  height: 1.35,
                ),
              ),
            ],
            if (hasMeaning) ...[
              const SizedBox(height: 8),
              Text(
                meaning!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: _accentColor(context),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_AnalysisItem> _buildAnalysisItems(AriaLineData line) {
    final vocabItems = _parseVocabItems(line.vocab);
    final ipaLines = _parseIpaLines(line.ipa);

    _debugAnalysisState(
      text: line.text,
      vocabItems: vocabItems,
      ipaLines: ipaLines,
    );

    final items = <_AnalysisItem>[];

    for (var i = 0; i < vocabItems.length; i++) {
      final vocabItem = vocabItems[i];
      final ipa = i < ipaLines.length ? ipaLines[i] : null;

      items.add(
        _AnalysisItem(
          word: vocabItem.word,
          ipa: ipa,
          meaning: vocabItem.meaning,
        ),
      );
    }

    return items;
  }

  List<_VocabItem> _parseVocabItems(String raw) {
    final lines = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final items = <_VocabItem>[];

    for (final line in lines) {
      final eqIndex = line.indexOf('=');

      if (eqIndex == -1) {
        final fallbackWord = line.trim();
        if (fallbackWord.isNotEmpty) {
          items.add(
            _VocabItem(
              word: fallbackWord,
              meaning: '',
            ),
          );
        }
        continue;
      }

      final word = line.substring(0, eqIndex).trim();
      final meaning = line.substring(eqIndex + 1).trim();

      if (word.isEmpty) continue;

      items.add(
        _VocabItem(
          word: word,
          meaning: meaning,
        ),
      );
    }

    return items;
  }

  List<String> _parseIpaLines(String raw) {
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _debugAnalysisState({
    required String text,
    required List<_VocabItem> vocabItems,
    required List<String> ipaLines,
  }) {
  }
}

class _AnalysisItem {
  final String word;
  final String? ipa;
  final String? meaning;

  const _AnalysisItem({
    required this.word,
    this.ipa,
    this.meaning,
  });
}

class _VocabItem {
  final String word;
  final String meaning;

  const _VocabItem({
    required this.word,
    required this.meaning,
  });
}
