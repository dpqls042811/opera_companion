import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _offlineStatus = '준비 중';

  bool _isDark(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
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

  Color _accentColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF8DBBFF)
        : const Color(0xFF2B79C2);
  }

  double _maxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1366) return 980;
    if (width >= 1024) return 900;
    if (width >= 900) return 840;
    return 760;
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '기기 설정 따름';
    }
  }

  Future<void> _handleOfflineDownload() async {
    if (!mounted) return;

    setState(() {
      _offlineStatus = '준비 중';
    });

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('오프라인 저장'),
        content: const Text(
          '오프라인 저장 기능은 아직 구현 중입니다.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return CupertinoPageScaffold(
          backgroundColor: _pageBackground(context),
          navigationBar: const CupertinoNavigationBar(
            middle: Text('설정'),
            previousPageTitle: '뒤로',
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _maxWidth(context)),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                  children: [
                    _sectionTitle(context, '화면 모드'),
                    const SizedBox(height: 10),
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '테마',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '라이트, 다크 또는 기기 설정을 따르도록 설정할 수 있습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: _secondaryText(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '현재 설정: ${_themeModeLabel(appSettings.themeMode)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _secondaryText(context),
                            ),
                          ),
                          const SizedBox(height: 14),
                          CupertinoSlidingSegmentedControl<ThemeMode>(
                            groupValue: appSettings.themeMode,
                            thumbColor: _groupColor(context),
                            backgroundColor: _isDark(context)
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFE9E9ED),
                            children: {
                              ThemeMode.light: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '라이트',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryText(context),
                                  ),
                                ),
                              ),
                              ThemeMode.dark: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '다크',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryText(context),
                                  ),
                                ),
                              ),
                              ThemeMode.system: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '기기 설정',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryText(context),
                                  ),
                                ),
                              ),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                appSettings.setThemeMode(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(context, '가사 표시'),
                    const SizedBox(height: 10),
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '가사 글자 크기',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${appSettings.lyricFontSize.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _secondaryText(context),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CupertinoSlider(
                            value: appSettings.lyricFontSize,
                            min: 16,
                            max: 34,
                            divisions: 18,
                            activeColor: _accentColor(context),
                            onChanged: (value) {
                              appSettings.setLyricFontSize(value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(context, '오프라인'),
                    const SizedBox(height: 10),
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오프라인 저장 (준비 중)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '오프라인 저장 기능은 현재 준비 중입니다.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: _secondaryText(context),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  color: _accentColor(context),
                                  borderRadius: BorderRadius.circular(14),
                                  onPressed: _handleOfflineDownload,
                                  child: const Text(
                                    '오프라인 저장 (준비 중)',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '상태: $_offlineStatus',
                            style: TextStyle(
                              fontSize: 14,
                              color: _secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(context, '앱 정보'),
                    const SizedBox(height: 10),
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aria App',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '아리아 가사, 해석, 발음을 보기 위한 학습용 앱입니다.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: _secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
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

  Widget _card(
    BuildContext context, {
    required Widget child,
  }) {
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
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
