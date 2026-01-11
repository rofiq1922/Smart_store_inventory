import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DbHelper {
  // Ganti nama key agar benar-benar fresh
  static const String _key = 'data_inventaris_final';

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString(_key);
      if (data != null) {
        List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("Error ambil data: $e");
    }
    return [];
  }

  Future<void> insertProduct(Map<String, dynamic> row) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> products = await getProducts();

      // Berikan ID unik
      row['id'] = DateTime.now().millisecondsSinceEpoch;
      products.add(row);

      // Simpan dan pastikan sukses
      bool success = await prefs.setString(_key, jsonEncode(products));
      print("Simpan data sukses? $success");
    } catch (e) {
      print("Gagal simpan ke database: $e");
    }
  }

  Future<void> updateProduct(Map<String, dynamic> row) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> products = await getProducts();
    int index = products.indexWhere((p) => p['id'] == row['id']);
    if (index != -1) {
      products[index] = row;
      await prefs.setString(_key, jsonEncode(products));
    }
  }

  Future<void> deleteProduct(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> products = await getProducts();
    products.removeWhere((p) => p['id'] == id);
    await prefs.setString(_key, jsonEncode(products));
  }
}
