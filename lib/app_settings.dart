import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String composersPath = 'assets/data/composers.json';
  static const String ariasPath = 'assets/data/arias.json';

  static const Map<String, String> ariaDetailPaths = {
    'leoncavallo_si_puo': 
        'assets/data/leoncavallo/si_puo.json',
    'mozart_hai_gia_vinta_la_causa':
        'assets/data/mozart/hai_gia_vinta_la_causa.json',
    'mozart_tutto_e_disposto':
        'assets/data/mozart/tutto_e_disposto.json',
    'mozart_rivolgete_a_lui_lo_sguardo':
        'assets/data/mozart/rivolgete_a_lui_lo_sguardo.json',
    'rossini_largo_al_factotum':
        'assets/data/rossini/largo_al_factotum.json',
    'verdi_cortigiani_vil_razza':
        'assets/data/verdi/cortigiani_vil_razza.json',
    'verdi_di_provenza_il_mar_il_suol':
        'assets/data/verdi/di_provenza_il_mar_il_suol.json',
    'verdi_eri_tu_che_macchiavi':
        'assets/data/verdi/eri_tu_che_macchiavi.json',
    'verdi_il_balen_del_suo_sorriso':
        'assets/data/verdi/il_balen_del_suo_sorriso.json',
    'verdi_per_me_giunto_io_morro':
        'assets/data/verdi/per_me_giunto_io_morro.json',
    'verdi_pieta_rispetto_amore':
        'assets/data/verdi/pieta_rispetto_amore.json',
    'wagner_o_du_mein_holder_abendstern':
        'assets/data/wagner/o_du_mein_holder_abendstern.json',
    'giordano_nemico_della_patria':
        'assets/data/giordano/nemico_della_patria.json',
    'gounod_avant_de_quitter_ces_lieux':
        'assets/data/gounod/avant_de_quitter_ces_lieux.json',
    'korngold_mein_sehnen_mein_wahnen':
        'assets/data/korngold/mein_sehnen_mein_wahnen.json',
    'donizetti_cruda_funesta_smania' :
        'assets/data/donizetti/cruda_funesta_smania.json',
  };

  static const _themeModeKey = 'theme_mode';
  static const _lyricFontSizeKey = 'lyric_font_size';

  ThemeMode _themeMode = ThemeMode.system;
  double _lyricFontSize = 18.0;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  double get lyricFontSize => _lyricFontSize;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeModeKey);
    final fontSize = prefs.getDouble(_lyricFontSizeKey);

    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    if (fontSize != null) {
      _lyricFontSize = fontSize;
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setLyricFontSize(double size) async {
    if (_lyricFontSize == size) return;
    _lyricFontSize = size;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lyricFontSizeKey, size);
  }
}

final AppSettings appSettings = AppSettings();
