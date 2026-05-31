import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/models/product_model.dart';
import 'package:toko_online/services/product_service.dart';
import 'package:toko_online/views/product_form_view.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final ProductService _productService = ProductService();
  List<ProductModel>? _products;
  bool _hasError = false;
  String _errorMessage = '';

  // ─── Monochrome Palette ───────────────────────────────────────
  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kCard    = Color(0xFF141414);
  static const kBorder  = Color(0xFF1E1E1E);
  static const kBorder2 = Color(0xFF2A2A2A);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _products = null;
      _hasError = false;
    });
    final result = await _productService.getProducts();
    if (!mounted) return;
    if (result.isUnauthorized) {
      // Token habis → paksa logout ke halaman login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }
    if (result.status) {
      setState(() {
        _products = List<ProductModel>.from(result.data ?? []);
      });
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = result.message;
      });
    }
  }

  /// Navigasi ke form dan refresh jika ada perubahan
  Future<void> _goToForm({ProductModel? item}) async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormView(item: item),
      ),
    );
    if (shouldRefresh == true) _fetchProducts();
  }

  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const BottomNav(1),
      // FAB tombol tambah produk baru
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToForm(),
        backgroundColor: kWhite,
        foregroundColor: kBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kBg,
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorder),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "KATALOG",
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: kGray2,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          Text(
            "Produk",
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: kWhite,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _fetchProducts,
          icon: const Icon(Icons.refresh_rounded, color: kGray1, size: 22),
          tooltip: "Refresh",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (_hasError) return _buildErrorState();
    if (_products == null) return _buildLoadingState();
    if (_products!.isEmpty) return _buildEmptyState();
    return _buildProductList();
  }

  // ─── Loading State ────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: kWhite,
              backgroundColor: kBorder2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Memuat produk...",
            style: GoogleFonts.poppins(fontSize: 13, color: kGray2),
          ),
        ],
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: kBorder2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: kGray2, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              "Gagal Memuat",
              style: GoogleFonts.poppins(
                  fontSize: 18, color: kWhite, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: kGray2),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _fetchProducts,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBorder2),
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Coba Lagi",
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(color: kBorder2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, color: kGray2, size: 28),
          ),
          const SizedBox(height: 20),
          Text("Belum ada produk",
              style: GoogleFonts.poppins(
                  fontSize: 16, color: kGray1, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text("Tekan + untuk menambahkan produk baru",
              style: GoogleFonts.poppins(fontSize: 12, color: kGray2)),
        ],
      ),
    );
  }

  // ─── Product List ─────────────────────────────────────────────
  Widget _buildProductList() {
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      color: kWhite,
      backgroundColor: kCard,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 90), // ruang untuk FAB
        itemCount: _products!.length,
        separatorBuilder: (_, __) => Container(height: 1, color: kBorder),
        itemBuilder: (context, index) =>
            _buildProductCard(_products![index]),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final imageUrl = product.image.isNotEmpty
        ? product.image
        : "https://picsum.photos/seed/prod${product.id}/200/200";
    final isLowStock  = product.stok > 0 && product.stok <= 5;
    final isOutOfStock = product.stok == 0;

    return InkWell(
      // Ketuk → buka form Edit
      onTap: () => _goToForm(item: product),
      splashColor: kBorder,
      highlightColor: kSurface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        color: kBg,
        child: Row(
          children: [
            // ── Image ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: kCard,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: kGray2, size: 24),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: kCard);
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.namaBarang,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: kWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.deskripsi,
                    style: GoogleFonts.poppins(fontSize: 11, color: kGray2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        _formatRupiah(product.harga),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: kWhite,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      _buildStockBadge(product.stok, isLowStock, isOutOfStock),
                    ],
                  ),
                ],
              ),
            ),

            // ── Edit arrow ──
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: kGray2, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(int stok, bool isLow, bool isOut) {
    Color borderColor;
    Color textColor;
    String label;

    if (isOut) {
      borderColor = kGray2;
      textColor   = kGray2;
      label       = "Habis";
    } else if (isLow) {
      borderColor = kGray1;
      textColor   = kGray1;
      label       = "$stok tersisa";
    } else {
      borderColor = kBorder2;
      textColor   = kGray1;
      label       = "Stok $stok";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}