import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko_online/models/cart.dart';

/// DBHelper yang kompatibel Web & Mobile.
/// Menyimpan cart sebagai JSON di SharedPreferences.
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static const String _cartKey = 'cart_data';

  // ─── Ambil semua item di cart ──────────────────────────────────
  Future<List<Cart>> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cartKey);
      if (raw == null || raw.isEmpty) return [];
      final List decoded = json.decode(raw) as List;
      return decoded.map((m) => Cart.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e) {
      debugPrint('DBHelper.getCart error: $e');
      return [];
    }
  }

  Future<void> _saveList(List<Cart> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((c) => c.toMap()).toList());
    await prefs.setString(_cartKey, encoded);
  }

  // ─── Simpan produk ke cart (insert / tambah qty jika sudah ada) ─
  Future<void> saveData(Cart cart) async {
    final items = await getCart();
    final idx = items.indexWhere((c) => c.idMovie == cart.idMovie);
    if (idx == -1) {
      // Beri id sementara berdasarkan waktu
      final newCart = Cart(
        id: DateTime.now().millisecondsSinceEpoch,
        idMovie: cart.idMovie,
        title: cart.title,
        voteAverage: cart.voteAverage,
        overview: cart.overview,
        quantity: cart.quantity,
        posterPath: cart.posterPath,
      );
      items.add(newCart);
    } else {
      items[idx].quantity += 1;
    }
    await _saveList(items);
  }

  // ─── Tambah quantity ──────────────────────────────────────────
  Future<void> addQuantity(int id) async {
    final items = await getCart();
    final idx = items.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final current = items[idx];
    items[idx] = Cart(
      id: current.id,
      idMovie: current.idMovie,
      title: current.title,
      voteAverage: current.voteAverage,
      overview: current.overview,
      quantity: current.quantity + 1,
      posterPath: current.posterPath,
    );
    await _saveList(items);
  }

  // ─── Kurangi quantity (hapus jika qty <= 1) ─────────────────────
  Future<void> deleteQuantity(int id) async {
    final items = await getCart();
    final idx = items.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final current = items[idx];
    if (current.quantity <= 1) {
      items.removeAt(idx);
    } else {
      items[idx] = Cart(
        id: current.id,
        idMovie: current.idMovie,
        title: current.title,
        voteAverage: current.voteAverage,
        overview: current.overview,
        quantity: current.quantity - 1,
        posterPath: current.posterPath,
      );
    }
    await _saveList(items);
  }

  // ─── Hapus satu item ──────────────────────────────────────────
  Future<void> deleteItem(int id) async {
    final items = await getCart();
    items.removeWhere((c) => c.id == id);
    await _saveList(items);
  }

  // ─── Hapus semua isi cart ─────────────────────────────────────
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // ─── Hitung total item di cart ─────────────────────────────────
  Future<int> getTotalItems() async {
    final items = await getCart();
    return items.fold<int>(0, (int sum, e) => sum + e.quantity);
  }
}