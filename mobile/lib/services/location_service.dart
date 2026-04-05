import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/location_model.dart';
import '../utils/location_manager.dart';

class LocationService {
  static const String _countriesCacheKey = 'cache_countries';
  static const String _citiesCacheKeyPrefix = 'cache_cities_';
  static const String _districtsCacheKeyPrefix = 'cache_districts_';

  Future<List<Country>> getCountries({bool refresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!refresh) {
      final cached = prefs.getString(_countriesCacheKey);
      if (cached != null) {
        final List<dynamic> data = jsonDecode(cached);
        return data.map((e) => Country.fromJson(e)).toList();
      }
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/location/countries'),
        headers: {"X-Platform": "Mobile"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        await prefs.setString(_countriesCacheKey, response.body);
        return data.map((e) => Country.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
    return [];
  }

  Future<List<City>> getCities(int countryId, {bool refresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_citiesCacheKeyPrefix$countryId';

    if (!refresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final List<dynamic> data = jsonDecode(cached);
        return data.map((e) => City.fromJson(e)).toList();
      }
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/location/cities/$countryId'),
        headers: {"X-Platform": "Mobile"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        await prefs.setString(cacheKey, response.body);
        return data.map((e) => City.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
    return [];
  }

  Future<List<District>> getDistricts(
    int cityId, {
    bool refresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_districtsCacheKeyPrefix$cityId';

    if (!refresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final List<dynamic> data = jsonDecode(cached);
        return data.map((e) => District.fromJson(e)).toList();
      }
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/location/districts/$cityId'),
        headers: {"X-Platform": "Mobile"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        await prefs.setString(cacheKey, response.body);
        return data.map((e) => District.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
    return [];
  }

  Future<void> saveSelectedLocation(District district, String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_location_id', district.id);
    await prefs.setString('selected_location_name', '${district.name}, $cityName');
    LocationManager().notifyChange();
  }

  Future<String?> getSelectedLocationName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_location_name');
    } catch (e) {
      return null;
    }
  }
}
