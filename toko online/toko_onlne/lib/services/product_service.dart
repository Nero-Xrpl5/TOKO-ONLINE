import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:toko_online/models/product_model.dart';
import 'package:toko_online/models/response_data_list.dart';
import 'package:toko_online/models/response_data_map.dart';
import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/services/url.dart' as url;

class ProductService {
  Future<ResponseDataList> getProducts() async {
    try {
      final userLogin = UserLogin();
      final user = await userLogin.getUserLogin();

      if (user.token == null || user.token!.isEmpty) {
        return ResponseDataList(
          status: false,
          message: "Token kosong, silakan login ulang.",
          isUnauthorized: true,
        );
      }

      final uri = Uri.parse("${url.BaseUrl}/admin/getbarang");
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer ${user.token}",
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
      } else if (response.statusCode == 401) {
        return ResponseDataList(
          status: false,
          message: "Sesi habis, silakan login ulang.",
          isUnauthorized: true,
        );
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

  Future<ResponseDataList> getProductsUser() async {
    try {
      final userLogin = UserLogin();
      final user = await userLogin.getUserLogin();

      if (user.token == null || user.token!.isEmpty) {
        return ResponseDataList(
          status: false,
          message: "Token kosong, silakan login ulang.",
          isUnauthorized: true,
        );
      }

      final uri = Uri.parse("${url.BaseUrl}/user/getbarang");
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer ${user.token}",
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
      } else if (response.statusCode == 401) {
        return ResponseDataList(
          status: false,
          message: "Sesi habis, silakan login ulang.",
          isUnauthorized: true,
        );
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

  /// Insert (id == null) atau Update (id != null) produk via MultipartRequest
  Future<ResponseDataMap> insertProduct({
    int? id,
    required String namaBarang,
    required String deskripsi,
    required String harga,
    required String stok,
    XFile? imageFile,
  }) async {
    try {
      final userLogin = UserLogin();
      final user = await userLogin.getUserLogin();

      final isUpdate = id != null;
      final uri = Uri.parse(
        isUpdate
            ? "${url.BaseUrl}/admin/updatebarang/$id"
            : "${url.BaseUrl}/admin/insertbarang",
      );

      final request = http.MultipartRequest("POST", uri);

      // Header autentikasi Bearer Token
      request.headers["Authorization"] = "Bearer ${user.token ?? ''}";
      request.headers["Accept"] = "application/json";

      // Field teks
      request.fields["nama_barang"] = namaBarang;
      request.fields["deskripsi"] = deskripsi;
      request.fields["harga"] = harga;
      request.fields["stok"] = stok;

      // File gambar (opsional saat update)
      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes("image", bytes, filename: imageFile.name),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath("image", imageFile.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("insertProduct response [${response.statusCode}]: ${response.body}");

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body["status"] == true) {
        return ResponseDataMap(
          status: true,
          message: isUpdate ? "Produk berhasil diperbarui" : "Produk berhasil ditambahkan",
          data: body,
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: body["message"]?.toString() ?? "Gagal menyimpan produk",
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Koneksi gagal: $e",
      );
    }
  }

  /// Hapus produk berdasarkan id
  Future<ResponseDataMap> deleteProduct(int id) async {
    try {
      final userLogin = UserLogin();
      final user = await userLogin.getUserLogin();

      final uri = Uri.parse("${url.BaseUrl}/admin/hapusbarang/$id");
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer ${user.token ?? ''}",
        "Accept": "application/json",
      });

      print("deleteProduct response [${response.statusCode}]: ${response.body}");

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body["status"] == true) {
        return ResponseDataMap(
          status: true,
          message: "Produk berhasil dihapus",
          data: body,
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: body["message"]?.toString() ?? "Gagal menghapus produk",
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Koneksi gagal: $e",
      );
    }
  }
}