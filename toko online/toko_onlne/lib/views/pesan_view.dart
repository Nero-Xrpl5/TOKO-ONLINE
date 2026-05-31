import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/models/cart.dart';
import 'package:toko_online/models/product_model.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/services/product_service.dart';
import 'package:toko_online/views/cart_screen.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class PesanView extends StatefulWidget {
  const PesanView({super.key});

  @override
  State<PesanView> createState() => _PesanViewState();
}

class _PesanViewState extends State<PesanView> {
  final ProductService _productService = ProductService();
  List<ProductModel>? _products;
  bool _hasError = false;
  String _errorMessage = '';

  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kCard    = Color(0xFF111111);
  static const kBorder  = Color(0xFF1A1A1A);
  static const kBorder2 = Color(0xFF262626);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    // Muat data cart saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _products = null;
      _hasError = false;
    });
    final result = await _productService.getProductsUser();
    if (!mounted) return;
    if (result.isUnauthorized) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }
    if (result.status) {
      setState(() => _products = List<ProductModel>.from(result.data ?? []));
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = result.message;
      });
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final cart = Cart(
      idMovie: product.id,
      title: product.namaBarang,
      voteAverage: product.harga.toDouble(),
      overview: product.deskripsi,
      quantity: 1,
      posterPath: product.image,
    );
    await context.read<CartProvider>().addToCart(cart);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${product.namaBarang} ditambahkan ke keranjang",
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: kCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: kBorder2),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const BottomNav(1),
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
              fontSize: 10,
              color: kGray2,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          Text(
            "Film",
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
        // ── Badge ikon keranjang (real-time) ──
        Consumer<CartProvider>(
          builder: (_, cart, __) {
            final total = cart.totalItems;
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ).then((_) => context.read<CartProvider>().loadCart()),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        color: kGray1, size: 24),
                    if (total > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: kWhite,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                              minWidth: 16, minHeight: 16),
                          child: Text(
                            total > 99 ? "99+" : total.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: kBg,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_hasError) return _buildErrorState();
    if (_products == null) return _buildLoadingState();
    if (_products!.isEmpty) return _buildEmptyState();
    return _buildProductList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: kWhite,
          backgroundColor: kBorder2,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: kBorder2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: kGray2, size: 28),
            ),
            const SizedBox(height: 20),
            Text("Gagal Memuat",
                style: GoogleFonts.poppins(
                    fontSize: 18, color: kWhite, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: kGray2)),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: _fetchProducts,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBorder2),
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, color: kGray2, size: 40),
          const SizedBox(height: 14),
          Text("Belum ada produk",
              style: GoogleFonts.poppins(
                  fontSize: 16, color: kGray1, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      color: kWhite,
      backgroundColor: kCard,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _products!.length,
        separatorBuilder: (_, __) => Container(height: 1, color: kBorder),
        itemBuilder: (_, i) => _buildProductCard(_products![i]),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final posterUrl = product.image.isNotEmpty
        ? product.image
        : "https://picsum.photos/seed/${product.id}/100/150";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: kBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gambar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              posterUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 64, height: 64, color: kCard),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(width: 64, height: 64, color: kSurface);
              },
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: kGray1, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      "Rp ${product.harga}",
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: kGray1),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.deskripsi,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: kGray2, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // ── Tombol Add to Cart ──
                GestureDetector(
                  onTap: () => _addToCart(product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorder2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_shopping_cart_rounded,
                            color: kGray1, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "Add to Cart",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: kGray1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}