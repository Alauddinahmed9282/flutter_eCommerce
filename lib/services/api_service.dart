import 'dart:convert';
import 'package:flutter_mastery/models/product.model.dart';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';

class ApiService {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  Future<List<Product>> syncProductsWithApi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      print('Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        print('Data Length: ${body.length}');

        List<Product> products = body
            .map((item) => Product.fromJson(item))
            .toList();

        await DatabaseHelper.instance.insertProducts(products);

        return await DatabaseHelper.instance.getLocalProducts();
      } else {
        throw "Server Error";
      }
    } catch (e) {
      print('Error loading data: $e'); // এটি আপনাকে বলবে আসলে কেন লোড হচ্ছে না
      return await DatabaseHelper.instance.getLocalProducts();
    }
  }
}
