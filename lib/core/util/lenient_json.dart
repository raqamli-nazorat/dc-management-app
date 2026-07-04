import 'dart:convert';

/// `raw`ni `Map<String, dynamic>` sifatida dekodlashga urinadi. Backend
/// ba'zan maydonni (masalan `extra_data`) JSON `null` o'rniga tirnoqsiz
/// Python token (`None`/`True`/`False`) bilan yuborib qo'yishi mumkin —
/// bu butun JSON matnini yaroqsiz qiladi va `jsonDecode` istisno tashlaydi.
/// Birinchi urinish muvaffaqiyatsiz bo'lsa, shu tokenlarni JSON ekvivalentiga
/// almashtirib qayta uriniladi. Ikkalasi ham muvaffaqiyatsiz bo'lsa `null`.
Map<String, dynamic>? lenientJsonDecode(String raw) {
  Map<String, dynamic>? tryParse(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {
      // e'tiborsiz — pastda sanitizatsiya qilingan variant bilan qayta uriniladi.
    }
    return null;
  }

  final direct = tryParse(raw);
  if (direct != null) return direct;

  final sanitized = raw
      .replaceAll(RegExp(r':\s*None\b'), ': null')
      .replaceAll(RegExp(r':\s*True\b'), ': true')
      .replaceAll(RegExp(r':\s*False\b'), ': false');
  return tryParse(sanitized);
}
