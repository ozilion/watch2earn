import 'package:flutter/material.dart';

class AppColors {
  // Ana Marka Renkleri
  static const Color primaryColor = Color(0xFF7747FF); // Mor rengi daha cazip hale getirildi
  static const Color secondaryColor = Color(0xFF00D0B3); // Turkuaz tonu daha canlı
  static const Color accentColor = Color(0xFFFF4785); // Pembe aksent rengi eklendi
  static const Color tertiaryColor = Color(0xFFFFC857); // Altın/Sarı renk
  static const Color errorColor = Color(0xFFFF4B55); // Daha parlak hata rengi

  // Arkaplan Renkleri
  static const Color lightBackground = Color(0xFFF8F9FC); // Çok açık mavi tonlu beyaz
  static const Color darkBackground = Color(0xFF0F1225); // Koyu lacivert

  // Yüzey Renkleri
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1A1F35); // Daha mavi tonlu koyu renk
  static const Color lightSurfaceVariant = Color(0xFFF0F3FA); // Açık yüzey varyantı
  static const Color darkSurfaceVariant = Color(0xFF252A40); // Koyu yüzey varyantı

  // Metin Renkleri
  static const Color lightTextColor = Color(0xFF151730); // Koyu lacivert metin
  static const Color darkTextColor = Color(0xFFF0F3FA); // Açık mavi tonlu beyaz metin
  static const Color lightTextSecondary = Color(0xFF6C7A93); // İkincil metin rengi
  static const Color darkTextSecondary = Color(0xFFADB5C5); // Koyu temada ikincil metin

  // Ayırıcı Renkleri
  static const Color lightDividerColor = Color(0xFFE0E5ED);
  static const Color darkDividerColor = Color(0xFF353A50);

  // Derecelendirme Renkleri
  static const Color ratingColor = Color(0xFFFFCE54);

  // Token Renkleri
  static const Color tokenColor = Color(0xFFFFD233); // Daha parlak altın tonu
  static const Color tokenSecondaryColor = Color(0xFFF5A623); // Turuncu altın tonu

  // Durum Renkleri
  static const Color successColor = Color(0xFF44D58C); // Başarı yeşili
  static const Color warningColor = Color(0xFFFFBB33); // Uyarı sarısı
  static const Color infoColor = Color(0xFF33AAFF); // Bilgi mavisi

  // Gradyan Renkleri
  static const List<Color> primaryGradient = [
    Color(0xFF7747FF), // Mor
    Color(0xFF9C6FFF), // Açık mor
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFF4785), // Pembe
    Color(0xFFFF80AB), // Açık pembe
  ];

  static const List<Color> tokenGradient = [
    Color(0xFFFFD233), // Altın
    Color(0xFFF5A623), // Turuncu altın
  ];

  static const List<Color> posterGradient = [
    Color(0x00151730),
    Color(0xE6151730),
  ];

  static const List<Color> featuredGradient = [
    Color(0xFF7747FF), // Mor
    Color(0xFF00D0B3), // Turkuaz
  ];

  // Shimmer Renkleri
  static const Color shimmerBaseColor = Color(0xFFE0E5ED);
  static const Color shimmerHighlightColor = Color(0xFFF8F9FC);
  static const Color darkShimmerBaseColor = Color(0xFF252A40);
  static const Color darkShimmerHighlightColor = Color(0xFF353A50);

  // Kart Renkleri
  static const List<Color> cardGradient1 = [Color(0xFF7747FF), Color(0xFF9C6FFF)];
  static const List<Color> cardGradient2 = [Color(0xFF00D0B3), Color(0xFF6AECDA)];
  static const List<Color> cardGradient3 = [Color(0xFFFF4785), Color(0xFFFF80AB)];
  static const List<Color> cardGradient4 = [Color(0xFFFFC857), Color(0xFFFFD98B)];

  // Çeşitli renk paletleri
  static const List<Color> colorPalette = [
    Color(0xFF7747FF), // Mor
    Color(0xFF00D0B3), // Turkuaz
    Color(0xFFFF4785), // Pembe
    Color(0xFFFFC857), // Altın
    Color(0xFF44D58C), // Yeşil
  ];
}