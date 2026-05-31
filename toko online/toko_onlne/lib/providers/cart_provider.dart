import 'package:flutter/material.dart';
import 'package:toko_online/models/cart.dart';
import 'package:toko_online/models/db_helper.dart';

class CartProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();

  List<Cart> _items = [];
  List<Cart> get items => _items;

  int get totalItems => _items.fold(0, (sum, e) => sum + e.quantity);

  // ─── Muat semua item dari SQLite ─────────────────────────────
  Future<void> loadCart() async {
    _items = await _db.getCart();
    notifyListeners();
  }

  // ─── Tambah film ke cart ──────────────────────────────────────
  Future<void> addToCart(Cart cart) async {
    await _db.saveData(cart);
    await loadCart();
  }

  // ─── Tambah quantity ──────────────────────────────────────────
  Future<void> addQuantity(int id) async {
    await _db.addQuantity(id);
    await loadCart();
  }

  // ─── Kurangi quantity ─────────────────────────────────────────
  Future<void> deleteQuantity(int id) async {
    await _db.deleteQuantity(id);
    await loadCart();
  }

  // ─── Hapus item ───────────────────────────────────────────────
  Future<void> deleteItem(int id) async {
    await _db.deleteItem(id);
    await loadCart();
  }

  // ─── Kosongkan cart (setelah checkout) ───────────────────────
  Future<void> clearCart() async {
    await _db.clearCart();
    await loadCart();
  }
}