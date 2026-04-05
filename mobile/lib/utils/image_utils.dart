import 'dart:math';

class ImageUtils {
  /// Sabit olan "mobile/assets/images/" (veya flutter içindeki 'assets/images')
  /// klasör ismini değiştirmeye olanak sağlayan, varsayılan olarak 'assets/images' 
  /// kullanan rastgele bir cami fotoğrafı getirme fonksiyonu.
  static String getRandomCamiImage({String basePath = 'assets/images'}) {
    // assets/images/cami altında cami-1.jpg ile cami-9.jpg arası 9 adet dosya bulunuyor.
    final int randomNumber = Random().nextInt(9) + 1; // 1 ile 9 arası (dahil) sayı üretir
    return '$basePath/cami/cami-$randomNumber.jpg';
  }

  /// assets/images/dini alti (religion)
  static String getRandomDiniImage({String basePath = 'assets/images'}) {
    final int randomNumber = Random().nextInt(4) + 1; // 1 ile 4 arası (dahil) sayı üretir
    return '$basePath/dini/dini-$randomNumber.jpg';
  }
}
