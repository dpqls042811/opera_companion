import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aria_data.dart';
import 'composer_screen.dart';
import 'data/load_all_arias.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

enum AppSection {
  home,
  composers,
  search,
  settings,
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  static const String _sidebarCollapsedKey = 'sidebar_collapsed';

  late final Future<List<AriaSummary>> allAriasFuture;
  late final Future<List<ComposerData>> composersFuture;

  AppSection selectedSection = AppSection.home;
  bool isSidebarCollapsed = false;
  bool isSidebarReady = false;

  @override
  void initState() {
    super.initState();
    allAriasFuture = AllAriasRepository.loadAllArias();
    composersFuture = AllAriasRepository.loadComposers();
    _loadSidebarState();
  }

  Future<void> _loadSidebarState() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_sidebarCollapsedKey) ?? false;

    if (!mounted) return;
    setState(() {
      isSidebarCollapsed = value;
      isSidebarReady = true;
    });
  }

  Future<void> _saveSidebarState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sidebarCollapsedKey, value);
  }

  void _toggleSidebar() {
    final next = !isSidebarCollapsed;
    setState(() {
      isSidebarCollapsed = next;
    });
    _saveSidebarState(next);
  }

  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);

    if (wide && !isSidebarReady) {
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(radius: 16),
        ),
      );
    }

    return FutureBuilder<List<AriaSummary>>(
      future: allAriasFuture,
      builder: (context, ariaSnapshot) {
        if (ariaSnapshot.connectionState != ConnectionState.done) {
          return const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(radius: 16),
            ),
          );
        }

        if (ariaSnapshot.hasError) {
          return CupertinoPageScaffold(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Arias load error:\n${ariaSnapshot.error}'),
              ),
            ),
          );
        }

        final arias = ariaSnapshot.data ?? [];

        return FutureBuilder<List<ComposerData>>(
          future: composersFuture,
          builder: (context, composerSnapshot) {
            if (composerSnapshot.connectionState != ConnectionState.done) {
              return const CupertinoPageScaffold(
                child: Center(
                  child: CupertinoActivityIndicator(radius: 16),
                ),
              );
            }

            if (composerSnapshot.hasError) {
              return CupertinoPageScaffold(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Composers load error:\n${composerSnapshot.error}'),
                  ),
                ),
              );
            }

            final composers = composerSnapshot.data ?? [];

            if (wide) {
              return _WideRootLayout(
                selectedSection: selectedSection,
                isCollapsed: isSidebarCollapsed,
                onToggle: _toggleSidebar,
                onSelect: (section) {
                  setState(() {
                    selectedSection = section;
                  });
                },
                content: _buildContent(selectedSection, arias, composers),
              );
            }

            return CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                activeColor: CupertinoColors.systemPink,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.house_fill),
                    label: '홈',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.music_note_2),
                    label: '작곡가',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.search),
                    label: '검색',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings_solid),
                    label: '설정',
                  ),
                ],
              ),
              tabBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      builder: (_) => HomeScreen(
                        arias: arias,
                        composers: composers,
                      ),
                    );
                  case 1:
                    return CupertinoTabView(
                      builder: (_) => ComposerScreen(
                        composers: composers,
                        allArias: arias,
                      ),
                    );
                  case 2:
                    return CupertinoTabView(
                      builder: (_) => SearchScreen(
                        arias: arias,
                      ),
                    );
                  case 3:
                    return CupertinoTabView(
                      builder: (_) => const SettingsScreen(),
                    );
                  default:
                    return CupertinoTabView(
                      builder: (_) => HomeScreen(
                        arias: arias,
                        composers: composers,
                      ),
                    );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    AppSection section,
    List<AriaSummary> arias,
    List<ComposerData> composers,
  ) {
    switch (section) {
      case AppSection.home:
        return HomeScreen(arias: arias, composers: composers);
      case AppSection.composers:
        return ComposerScreen(composers: composers, allArias: arias);
      case AppSection.search:
        return SearchScreen(arias: arias);
      case AppSection.settings:
        return const SettingsScreen();
    }
  }
}

class _WideRootLayout extends StatelessWidget {
  final AppSection selectedSection;
  final bool isCollapsed;
  final VoidCallback onToggle;
  final ValueChanged<AppSection> onSelect;
  final Widget content;

  const _WideRootLayout({
    required this.selectedSection,
    required this.isCollapsed,
    required this.onToggle,
    required this.onSelect,
    required this.content,
  });

  bool _isDark(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final sidebarColor = _isDark(context)
        ? const Color(0xFF111113)
        : const Color(0xFFEDEDF3);

    final dividerColor = _isDark(context)
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFD1D1D6);

    final labelColor =
        CupertinoTheme.of(context).textTheme.textStyle.color ??
            CupertinoColors.label;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: isCollapsed ? 88 : 290,
              color: sidebarColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onToggle,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isDark(context)
                              ? const Color(0xFF1C1C1E)
                              : CupertinoColors.white.withOpacity(0.78),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: isCollapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            SizedBox(width: isCollapsed ? 0 : 14),
                            Icon(
                              CupertinoIcons.sidebar_left,
                              size: 20,
                              color: labelColor,
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(width: 10),
                              Text(
                                '메뉴 접기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: labelColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SidebarItem(
                    title: '홈',
                    icon: CupertinoIcons.house_fill,
                    selected: selectedSection == AppSection.home,
                    collapsed: isCollapsed,
                    onTap: () => onSelect(AppSection.home),
                  ),
                  _SidebarItem(
                    title: '작곡가',
                    icon: CupertinoIcons.music_note_2,
                    selected: selectedSection == AppSection.composers,
                    collapsed: isCollapsed,
                    onTap: () => onSelect(AppSection.composers),
                  ),
                  _SidebarItem(
                    title: '검색',
                    icon: CupertinoIcons.search,
                    selected: selectedSection == AppSection.search,
                    collapsed: isCollapsed,
                    onTap: () => onSelect(AppSection.search),
                  ),
                  _SidebarItem(
                    title: '설정',
                    icon: CupertinoIcons.settings_solid,
                    selected: selectedSection == AppSection.settings,
                    collapsed: isCollapsed,
                    onTap: () => onSelect(AppSection.settings),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              color: dividerColor,
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? CupertinoColors.systemPink.withOpacity(0.14)
        : CupertinoColors.transparent;

    final fg = selected
        ? CupertinoColors.systemPink
        : CupertinoTheme.of(context).textTheme.textStyle.color ??
            CupertinoColors.label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: fg),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.15,
                    color: fg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
