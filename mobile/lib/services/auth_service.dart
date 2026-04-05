import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  static const String baseUrl = "${AppConfig.baseUrl}/auth";

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("AuthService: Base URL: $baseUrl");
      print("AuthService: Attempting login for $email");
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: {
              "Content-Type": "application/json",
              "X-Platform": "Mobile",
            },
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print("AuthService: Login status code: ${response.statusCode}");
      print("AuthService: Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both camelCase and PascalCase
        if (data["Token"] != null) data["token"] = data["Token"];
        return data;
      } else {
        return {"error": "Giriş başarısız", "status": response.statusCode};
      }
    } catch (e) {
      print("AuthService: Login error: $e");
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String language,
  ) async {
    try {
      print("AuthService: Base URL: $baseUrl");
      print("AuthService: Attempting register for $email");
      final response = await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: {
              "Content-Type": "application/json",
              "X-Platform": "Mobile",
            },
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
              "language": language.toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      print("AuthService: Register status code: ${response.statusCode}");
      print("AuthService: Register response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both camelCase and PascalCase
        if (data["Id"] != null) data["id"] = data["Id"];
        return data;
      } else {
        return {"error": "Kayıt başarısız", "status": response.statusCode};
      }
    } catch (e) {
      print("AuthService: Register error: $e");
      return {"error": e.toString()};
    }
  }
}
