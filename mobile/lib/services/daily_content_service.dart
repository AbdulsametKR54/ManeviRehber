import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/daily_content_model.dart';
import 'dart:math';

class DailyContentService {
  Future<DailyContentModel?> getRandomDailyContent() async {
    return getDailyContentByTag(''); // Boş tag tüm içeriklerden rastgele getirir
  }

  Future<DailyContentModel?> getDailyContentByTag(String tag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Daha geniş bir yelpazeden arama yapmak için pageSize'ı artırıyoruz
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/DailyContents/paged?pageSize=50'),
        headers: {
          "X-Platform": "Mobile",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('DailyContent Error: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? data['Items'] ?? [];
      
      if (items.isEmpty) return null;

      final contents = items.map((json) => DailyContentModel.fromJson(json)).toList();

      List<DailyContentModel> filteredContents = contents;
      if (tag.isNotEmpty) {
        filteredContents = contents.where((item) {
          // Check typeName
          if (item.typeName.toLowerCase() == tag.toLowerCase()) return true;
          // Check categories
          if (item.categories.any((c) => c.toLowerCase() == tag.toLowerCase())) return true;
          // Fallback search in title/content
          return item.title.toLowerCase().contains(tag.toLowerCase()) || 
                 item.content.toLowerCase().contains(tag.toLowerCase());
        }).toList();
      }

      if (filteredContents.isEmpty) {
        // Tag bulunamazsa tümü içinden rastgele bir tane dön
        final random = Random();
        return contents[random.nextInt(contents.length)];
      }

      final random = Random();
      return filteredContents[random.nextInt(filteredContents.length)];

    } catch (e) {
      print('DailyContent Exception: $e');
      return null;
    }
  }
}
