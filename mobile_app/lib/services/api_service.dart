import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';

class ApiService {
  static const String baseUrl = AppTheme.apiBaseUrl;
  static const String appToken = AppTheme.appToken;

  // Save token to Shared Preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Get token from Shared Preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Logout / clear token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Common Headers helper
  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-app-token': appToken,
    };
    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String sponsorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'mobileNumber': mobileNumber,
          'password': password,
          'sponsor_id': sponsorId,
          'device_model': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
          'app_version': '1.0.0',
        }),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': decoded['message']};
      } else {
        return {'success': false, 'error': decoded['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: Could not connect to server'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_model': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
          'app_version': '1.0.0',
        }),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveToken(decoded['token']);
        return {'success': true, 'user': decoded['user']};
      } else {
        return {'success': false, 'error': decoded['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: Could not connect to server'};
    }
  }

  // Get Profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: await _getHeaders(requireAuth: true),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'user': decoded};
      } else {
        return {'success': false, 'error': decoded['error'] ?? 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: Could not connect to server'};
    }
  }

  // Submit deposit request for approval
  static Future<Map<String, dynamic>> submitFundRequest(double amount, String utr) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/fund/request'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'amount': amount, 'utr': utr}),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': decoded['message']};
      } else {
        return {'success': false, 'error': decoded['error'] ?? 'Request failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  // Fetch user's deposit requests
  static Future<List<dynamic>> getFundRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/fund/requests'),
        headers: await _getHeaders(requireAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // Trigger Razorpay sandbox payment simulation on successful payment
  static Future<Map<String, dynamic>> triggerRazorpaySandboxPayment(
      double amount, String serviceType, String walletType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/razorpay-sandbox'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({
          'amount': amount,
          'serviceType': serviceType,
          'walletType': walletType,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': decoded['message']};
      }
    } catch (_) {}
    return {'success': false, 'error': 'Server sync failed'};
  }

  // Activate Cycle ID
  static Future<Map<String, dynamic>> activateCycle() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cycles/activate'),
        headers: await _getHeaders(requireAuth: true),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': decoded['message'], 'cycleId': decoded['cycleId']};
      } else {
        return {'success': false, 'error': decoded['error'] ?? 'Activation failed'};
      }
    } catch (_) {
      return {'success': false, 'error': 'Server connection error'};
    }
  }

  // Get Cycles History list
  static Future<List<dynamic>> getCyclesHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cycles/history'),
        headers: await _getHeaders(requireAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // Submit Withdrawal Request
  static Future<Map<String, dynamic>> submitWithdrawal(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/withdrawal/request'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'amount': amount}),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': decoded['message']};
      } else {
        return {'success': false, 'error': decoded['error'] ?? 'Withdrawal failed'};
      }
    } catch (_) {
      return {'success': false, 'error': 'Server connection error'};
    }
  }
}
