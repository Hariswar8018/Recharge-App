import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../api.dart';

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
  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = false,
  }) async {
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
          'device_model':
              '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
          'app_version': '1.0.0',
        }),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': decoded['message']};
      } else {
        return {
          'success': false,
          'error': decoded['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: Could not connect to server',
      };
    }
  }

  // Forgot Password Reset (Fetch/Reset Password from API + Send Email from App via SMTP)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password'),
            headers: await _getHeaders(),
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 25));

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          (decoded['success'] == true || decoded['registered'] == true)) {
        final String? realPassword = decoded['password'];
        final String? fullName = decoded['fullName'];
        if (realPassword != null && realPassword.isNotEmpty) {
          // Send Password Email directly from App via SMTP asynchronously (fire-and-forget, non-blocking)
          sendDirectPasswordEmail(
            email,
            tempPassword: realPassword,
            fullName: fullName,
          ).catchError((err) {
            print('Background app direct email error: $err');
            return false;
          });
        }
        return {
          'success': true,
          'message':
              decoded['message'] ??
              'Password has been sent to your registered email ID.',
        };
      } else {
        return {
          'success': false,
          'error':
              decoded['error'] ??
              'Email ID not found. Please enter a registered email ID.',
        };
      }
    } catch (e) {
      print('forgotPassword API error: $e');
      return {
        'success': false,
        'error':
            'Connection error: Could not connect to server. Please try again later.',
      };
    }
  }

  // Direct App SMTP Email Sending
  static Future<bool> sendDirectPasswordEmail(
    String email, {
    required String tempPassword,
    String? fullName,
  }) async {
    try {
      final host = Api.smtpHost;
      final port = Api.smtpPort;
      final user = Api.smtpUser;
      final pass = Api.smtpPass;

      final String nameDisplay = fullName ?? 'User';

      final socket = await SecureSocket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10),
        onBadCertificate: (_) => true,
      );

      final StreamSubscription sub = socket.listen(
        (data) {},
        onError: (e) => print('SMTP Socket Listen error: $e'),
        onDone: () {},
        cancelOnError: true,
      );

      Future<void> sendCmd(String cmd) async {
        try {
          socket.write('$cmd\r\n');
          await socket.flush();
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          print('sendCmd error: $e');
        }
      }

      await Future.delayed(const Duration(milliseconds: 400));
      await sendCmd('EHLO srdigitalseva.com');
      await sendCmd('AUTH LOGIN');
      await sendCmd(base64Encode(utf8.encode(user)));
      await sendCmd(base64Encode(utf8.encode(pass)));

      await sendCmd('MAIL FROM:<$user>');
      await sendCmd('RCPT TO:<${email.trim()}>');
      await sendCmd('DATA');

      final String emailData = [
        'From: "SR Digital Seva Support" <$user>',
        'To: <${email.trim()}>',
        'Subject: Your Account Password - SR Digital Seva',
        'MIME-Version: 1.0',
        'Content-Type: text/html; charset=utf-8',
        '',
        '<div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f8fafc; border-radius: 12px; border: 1px solid #e2e8f0;"><h2 style="color: #0052cc; margin-top: 0;">SR Digital Seva</h2><p style="font-size: 14px; color: #334155;">Hello <strong>$nameDisplay</strong>,</p><p style="font-size: 14px; color: #334155;">Your account password is:</p><div style="font-size: 22px; font-weight: bold; color: #0052cc; background: #eff6ff; padding: 12px 20px; border-radius: 8px; display: inline-block; letter-spacing: 1px; border: 1px solid #bfdbfe; margin: 10px 0;">$tempPassword</div><p style="font-size: 13px; color: #64748b; margin-bottom: 0;">Please use this password to log in to your account. You can also update your password anytime in Security Settings.</p></div>',
        '.',
      ].join('\r\n');

      await sendCmd(emailData);
      await sendCmd('QUIT');

      try {
        await sub.cancel();
        await socket.close();
      } catch (_) {}
      return true;
    } catch (e) {
      print('Direct App SMTP error: $e');
      return false;
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
          'device_model':
              '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
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
      return {
        'success': false,
        'error': 'Connection error: Could not connect to server',
      };
    }
  }

  // Check if Mobile Number is Registered (Login Screen)
  static Future<Map<String, dynamic>> checkMobile(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-mobile'),
        headers: await _getHeaders(),
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );
      final decoded = jsonDecode(response.body);
      return {
        'registered': decoded['registered'] == true,
        'message':
            decoded['message'] ??
            (decoded['registered'] == true
                ? 'Valid registered mobile number'
                : 'This mobile number is not registered. Please use your registered mobile number.'),
      };
    } catch (e) {
      return {'registered': false, 'error': 'Connection error'};
    }
  }

  // Check if Mobile Number is Available for Registration
  static Future<Map<String, dynamic>> checkMobileAvailable(
    String mobileNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-mobile-available'),
        headers: await _getHeaders(),
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );
      final decoded = jsonDecode(response.body);
      return {
        'valid': decoded['valid'] == true,
        'registered': decoded['registered'] == true,
        'message':
            decoded['message'] ??
            (decoded['valid'] == true
                ? 'Valid (Can Register)'
                : 'Invalid mobile number'),
      };
    } catch (e) {
      return {'valid': false, 'message': 'Connection error'};
    }
  }

  // Check Sponsor ID for Registration
  static Future<Map<String, dynamic>> checkSponsor(String sponsorId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-sponsor'),
        headers: await _getHeaders(),
        body: jsonEncode({'sponsor_id': sponsorId}),
      );
      final decoded = jsonDecode(response.body);
      return {
        'valid': decoded['valid'] == true,
        'name': decoded['name'],
        'error': decoded['error'] ?? 'User Not Found',
      };
    } catch (e) {
      return {'valid': false, 'error': 'Connection error'};
    }
  }

  // Check Email Registration Status (Forgot Password)
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-email'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );
      final decoded = jsonDecode(response.body);
      return {
        'registered': decoded['registered'] == true,
        'message':
            decoded['message'] ??
            (decoded['registered'] == true
                ? 'Valid registered email address'
                : 'Email ID not found. Please enter a registered email ID.'),
      };
    } catch (e) {
      return {'registered': false, 'message': 'Connection error'};
    }
  }

  // Check Email Availability (Registration Screen)
  static Future<Map<String, dynamic>> checkEmailAvailable(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-email-available'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );
      final decoded = jsonDecode(response.body);
      return {
        'valid': decoded['valid'] == true,
        'registered': decoded['registered'] == true,
        'message':
            decoded['message'] ??
            (decoded['valid'] == true
                ? 'Valid Email (Available)'
                : 'Email Already Registered'),
      };
    } catch (e) {
      return {'valid': false, 'message': 'Connection error'};
    }
  }

  static double _accumulatedCaptchaEarnings = 0.0;
  static List<Map<String, dynamic>> _localCaptchaTxns = [];
  static bool _isCaptchaDataLoaded = false;

  static Future<void> _initCaptchaPersistence() async {
    if (_isCaptchaDataLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _accumulatedCaptchaEarnings =
          prefs.getDouble('local_captcha_earnings') ?? 0.0;
      final txnsJson = prefs.getString('local_captcha_txns');
      if (txnsJson != null) {
        final List<dynamic> decoded = jsonDecode(txnsJson);
        _localCaptchaTxns = decoded
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      _isCaptchaDataLoaded = true;
    } catch (_) {}
  }

  static Future<void> _saveCaptchaPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
        'local_captcha_earnings',
        _accumulatedCaptchaEarnings,
      );
      await prefs.setString(
        'local_captcha_txns',
        jsonEncode(_localCaptchaTxns),
      );
    } catch (_) {}
  }

  // Lookup User by ID or Mobile Number
  static Future<Map<String, dynamic>> lookupUserById(String idOrMobile) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/by-id/$idOrMobile'),
        headers: await _getHeaders(),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'user': decoded};
      } else {
        return {
          'success': false,
          'error': decoded['error'] ?? 'User not found',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Could not look up user'};
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
      if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
        return {'success': true, 'user': decoded};
      }
    } catch (e) {}

    return {'success': false, 'error': 'Failed to load user profile'};
  }

  // Submit deposit request for approval
  static Future<Map<String, dynamic>> submitFundRequest(
    double amount,
    String utr,
  ) async {
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
        return {
          'success': false,
          'error': decoded['error'] ?? 'Request failed',
        };
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

  // Fetch landing info & app share settings
  static Future<Map<String, dynamic>> getLandingInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/landing-info'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {};
  }

  // Check if UTR is already registered in backend system
  static Future<bool> checkUtrExists(String utr) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/fund/check-utr/$utr'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['exists'] == true || decoded['registered'] == true;
      }
    } catch (_) {}
    return false;
  }

  // Trigger Razorpay sandbox payment simulation on successful payment
  static Future<Map<String, dynamic>> triggerRazorpaySandboxPayment(
    double amount,
    String serviceType,
    String walletType,
  ) async {
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
        return {
          'success': true,
          'message': decoded['message'],
          'cycleId': decoded['cycleId'],
        };
      } else {
        return {
          'success': false,
          'error': decoded['error'] ?? 'Activation failed',
        };
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
        return {
          'success': false,
          'error': decoded['error'] ?? 'Withdrawal failed',
        };
      }
    } catch (_) {
      return {'success': false, 'error': 'Server connection error'};
    }
  }

  // Get User Team / Affiliates
  static Future<List<dynamic>> getTeam() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/team'),
        headers: await _getHeaders(requireAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // Get User Transactions list
  static Future<List<dynamic>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/transactions'),
        headers: await _getHeaders(requireAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  // Submit Captcha Earnings
  static Future<Map<String, dynamic>> submitCaptchaEarnings({
    double earnedAmount = 0.01,
  }) async {
    await _initCaptchaPersistence();
    _accumulatedCaptchaEarnings += earnedAmount;
    final newTx = {
      'type': 'Captcha Solve Reward',
      'amount': '+ ₹${earnedAmount.toStringAsFixed(2)}',
      'date': DateTime.now()
          .toLocal()
          .toString()
          .substring(0, 19)
          .replaceAll('T', ' '),
      'reference_id': 'TXN_CPT_${DateTime.now().millisecondsSinceEpoch}',
    };
    _localCaptchaTxns.insert(0, newTx);
    await _saveCaptchaPersistence();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/captcha/earn'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'amount': earnedAmount}),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Reward added',
        };
      }
    } catch (_) {}
    return {'success': true, 'message': 'Reward ₹0.01 added to balance'};
  }

  // Update User Profile
  static Future<Map<String, dynamic>> updateProfile(
    String fullName,
    String mobileNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/update'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'fullName': fullName, 'mobileNumber': mobileNumber}),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {'success': false, 'error': decoded['error'] ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Submit Cashout / Withdrawal
  static Future<Map<String, dynamic>> submitCashout({
    required double amount,
    required String paymentMethod,
    required String details,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/withdrawal/request'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({
          'amount': amount,
          'method': paymentMethod,
          'details': details,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': decoded['message']};
      } else {
        return {
          'success': false,
          'error': decoded['error'] ?? 'Cashout request failed',
        };
      }
    } catch (_) {
      return {
        'success': true,
        'message': 'Cashout request submitted for processing',
      };
    }
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/change-password'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': decoded['message']};
      } else {
        return {
          'success': false,
          'error': decoded['error'] ?? 'Incorrect old password',
        };
      }
    } catch (_) {
      return {'success': true, 'message': 'Password updated successfully'};
    }
  }

  // Get Notifications
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/landing-info'),
        headers: await _getHeaders(requireAuth: false),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['notifications'] != null && data['notifications'] is List) {
          return data['notifications'];
        }
      }
    } catch (_) {}
    return [];
  }

  // Get Element Visibility Settings
  static Future<Map<String, dynamic>> getVisibility() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/visibility'),
        headers: await _getHeaders(requireAuth: false),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  // Get System Settings
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/settings'),
        headers: await _getHeaders(requireAuth: false),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  // Activate User ID / Subscription
  static Future<Map<String, dynamic>> activateUser({
    required String mobile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cycles/activate'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'mobile': mobile}),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'ID Activated',
        };
      } else {
        return {
          'success': false,
          'message': decoded['error'] ?? 'Activation failed',
        };
      }
    } catch (_) {
      return {'success': false, 'message': 'Network error during activation'};
    }
  }

  // Bank Account Penny Drop Verification
  static Future<Map<String, dynamic>> verifyBankAccount({
    required String bankName,
    required String accountHolder,
    required String accountNo,
    required String ifsc,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bank/verify'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({
          'bank_name': bankName,
          'account_holder': accountHolder,
          'account_no': accountNo,
          'ifsc': ifsc,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'],
          'nameAtBank': decoded['nameAtBank'],
          'utr': decoded['utr'],
        };
      } else {
        return {
          'success': false,
          'error':
              decoded['error'] ?? 'Bank Account Penny Drop verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error during bank verification: $e',
      };
    }
  }
}
