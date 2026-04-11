import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/favorite_model.dart';

class FavoriteService {
  static const String baseUrl = "${AppConfig.baseUrl}/Favorites";

  Future<List<FavoriteModel>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FavoriteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('FavoriteService getFavorites error: $e');
      return [];
    }
  }

  Future<bool> addFavorite(FavoriteModel favorite) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(favorite.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('FavoriteService addFavorite error: $e');
      return false;
    }
  }

  Future<bool> deleteFavorite(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('FavoriteService deleteFavorite error: $e');
      return false;
    }
  }
}
