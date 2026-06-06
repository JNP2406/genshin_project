import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.135.100.84:3000';

  // Build full image URL
static String buildImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return '';
  if (imagePath.contains('/uploads/')) {
    final filename = imagePath.split('/uploads/').last;
    return 'http://10.135.100.84:3000/uploads/$filename';
  }
  
  return 'http://10.135.100.84:3000/uploads/$imagePath';
}

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Save user data to SharedPreferences
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
    await prefs.setDouble('user_mora', user.mora);

    await prefs.remove('user_profile_picture');
    await prefs.remove('user_cover_photo');
    await prefs.remove('user_bio');

    if (user.profilePicture != null) {
      await prefs.setString('user_profile_picture', user.profilePicture!);
    }
    if (user.coverPhoto != null) {
     await prefs.setString('user_cover_photo', user.coverPhoto!);
    }
    if (user.bio != null) {
      await prefs.setString('user_bio', user.bio!);
    }
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_mora');
    await prefs.remove('user_profile_picture'); 
    await prefs.remove('user_cover_photo');     
    await prefs.remove('user_bio');  
  }

  // =====================
  // AUTH
  // =====================

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(
      String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // =====================
  // ITEMS
  // =====================

  static Future<List<ItemModel>> getItems({
    String? category,
    String? type,
    String? search,
  }) async {
    try {
      String url = '$baseUrl/items';
      List<String> params = [];
      if (category != null) params.add('category=$category');
      if (type != null) params.add('type=$type');
      if (search != null) params.add('search=$search');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => ItemModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<ItemModel?> getItemById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items/$id'));
      final data = jsonDecode(response.body);
      if (data['success']) {
        return ItemModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createItem(
      Map<String, dynamic> itemData, String imagePath) async {
    try {
      final token = await getToken();
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/items'));
      request.headers['Authorization'] = 'Bearer $token';
      itemData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      request.files
          .add(await http.MultipartFile.fromPath('image', imagePath));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateItem(
      int id, Map<String, dynamic> itemData, String? imagePath) async {
    try {
      final token = await getToken();
      final request =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/items/$id'));
      request.headers['Authorization'] = 'Bearer $token';
      itemData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      if (imagePath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      }
      final response = await request.send();
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteItem(int id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Authorization': 'Bearer $token'},  
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // =====================
  // TRANSACTIONS
  // =====================

  static Future<Map<String, dynamic>> buyItem(
      int itemId, int quantity) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/buy'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'item_id': itemId, 'quantity': quantity}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<List<TransactionModel>> getMyTransactions() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/my'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/all'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // =====================
  // TOPUP
  // =====================

  static Future<Map<String, dynamic>> topUp(
      int moraAmount, double price) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/topup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'mora_amount': moraAmount, 'price': price}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // =====================
  // PROFILE
  // =====================

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
    String? profilePicturePath,
    String? coverPhotoPath,
    {bool removeProfilePicture = false,
    bool removeCoverPhoto = false}) async {
  try {
    final token = await getToken();
    final request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile'));
    request.headers['Authorization'] = 'Bearer $token';
    profileData.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (removeProfilePicture) {
      request.fields['remove_profile_picture'] = 'true';
    }
    if (removeCoverPhoto) {
      request.fields['remove_cover_photo'] = 'true';
    }
    if (profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', profilePicturePath));
    }
    if (coverPhotoPath != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'cover_photo', coverPhotoPath));
    }
    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}
}