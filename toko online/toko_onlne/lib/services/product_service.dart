import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toko_online/models/product_model.dart';
import 'package:toko_online/models/response_data_list.dart';
import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/services/url.dart' as url;

class ProductService {
  Future<ResponseDataList> getProducts() async {
    try {
      final userLogin = UserLogin();
      final user = await userLogin.getUserLogin();

      final uri = Uri.parse("${url.BaseUrl}/admin/getbarang");
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer ${user.token ?? ''}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body["status"] == true) {
          final List<ProductModel> products = (body["data"] as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          return ResponseDataList(
            status: true,
            message: "Berhasil mengambil data produk",
            data: products,
          );
        } else {
          return ResponseDataList(
            status: false,
            message: body["message"] ?? "Gagal mengambil data",
          );
        }
      } else {
        return ResponseDataList(
          status: false,
          message: "Server error: ${response.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: "Koneksi gagal: $e",
      );
    }
  }
}