import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/models/cart.dart';
import 'package:toko_online/providers/cart_provider.dart';

import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/services/url.dart' as url;
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kCard    = Color(0xFF111111);
  static const kBorder  = Color(0xFF1A1A1A);
  static const kBorder2 = Color(0xFF262626);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);

  static const String _imgBase = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  // ─── Checkout ─────────────────────────────────────────────────
  Future<void> _checkout(List<Cart> items) async {
    if (items.isEmpty) return;
    setState(() => _isCheckingOut = true);

    try {
      final userLogin = UserLogin();
      final user = await userLogin.getUserLogin();

      final uri = Uri.parse("${url.BaseUrl}/user/transaksi");
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer ${user.token ?? ''}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "pesan": items.map((e) => e.toJson()).toList(),
        }),
      );

      if (!mounted) return;

      final body = json.decode(response.body);
      final success =
          response.statusCode == 200 && body["status"] == true;

      if (success) {
        // Bersihkan cart
        await context.read<CartProvider>().clearCart();

        if (!mounted) return;

        // Tampilkan dialog sukses → navigasi ke HistoryView (Remove Until)
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: kCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: kBorder2),
            ),
            title: Text(
              "Checkout Berhasil",
              style: GoogleFonts.poppins(
                  color: kWhite, fontWeight: FontWeight.w700),
            ),
            content: Text(
              body["message"] ?? "Pesanan kamu berhasil diproses.",
              style: GoogleFonts.poppins(color: kGray1, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  // Kembali ke halaman pesan, bersihkan stack
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/pesan',
                    (route) => route.settings.name == '/dashboard',
                  );
                },
                child: Text(
                  "Lihat Riwayat",
                  style: GoogleFonts.poppins(
                    color: kWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        _showSnack(body["message"]?.toString() ?? "Checkout gagal");
      }
    } catch (e) {
      if (mounted) _showSnack("Koneksi gagal: $e");
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: kCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: kBorder2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.items.isEmpty) return _buildEmptyCart();
          return _buildCartList(cart);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: kWhite, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorder),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PESANAN",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: kGray2,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          Text(
            "Keranjang",
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: kWhite,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              border: Border.all(color: kBorder2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: kGray2, size: 28),
          ),
          const SizedBox(height: 20),
          Text("Keranjang Kosong",
              style: GoogleFonts.poppins(
                  fontSize: 16, color: kGray1, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text("Tambahkan produk dari halaman katalog",
              style: GoogleFonts.poppins(fontSize: 12, color: kGray2)),
        ],
      ),
    );
  }

  Widget _buildCartList(CartProvider cart) {
    return Column(
      children: [
        // ── Daftar item ──
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => Container(height: 1, color: kBorder),
            itemBuilder: (_, i) => _buildCartItem(cart, cart.items[i]),
          ),
        ),

        // ── Footer checkout ──
        Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border(top: BorderSide(color: kBorder)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              // Total item info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Item",
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: kGray2)),
                  Text("${cart.totalItems} produk",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: kWhite,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // Tombol Checkout
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isCheckingOut
                      ? null
                      : () => _checkout(cart.items),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: kBg,
                    disabledBackgroundColor: kBorder2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isCheckingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kGray2,
                          ),
                        )
                      : Text(
                          "Checkout",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartProvider cart, Cart item) {
    final posterUrl = item.posterPath.isNotEmpty
        ? "$_imgBase${item.posterPath}"
        : "https://picsum.photos/seed/${item.idMovie}/100/150";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: kBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Poster ──
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              posterUrl,
              width: 56,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 56, height: 80, color: kCard),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info & Kontrol ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: kWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: kGray2, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      "Rp ${item.voteAverage.toInt()}",
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: kGray2),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Tombol tambah/kurang ──
                Row(
                  children: [
                    _buildQtyButton(
                      icon: Icons.remove_rounded,
                      onTap: () => cart.deleteQuantity(item.id!),
                    ),
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: Text(
                        item.quantity.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _buildQtyButton(
                      icon: Icons.add_rounded,
                      onTap: () => cart.addQuantity(item.id!),
                    ),
                    const Spacer(),

                    // ── Hapus item ──
                    GestureDetector(
                      onTap: () => cart.deleteItem(item.id!),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: kBorder2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: kGray2, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: kBorder2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: kGray1, size: 16),
      ),
    );
  }
}