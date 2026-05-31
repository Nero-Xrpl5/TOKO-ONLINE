import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_online/models/product_model.dart';
import 'package:toko_online/services/product_service.dart';

class ProductFormView extends StatefulWidget {
  /// Jika item != null → mode Update, jika null → mode Insert
  final ProductModel? item;

  const ProductFormView({super.key, this.item});

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late final TextEditingController _namaCtrl;
  late final TextEditingController _deskripsiCtrl;
  late final TextEditingController _hargaCtrl;
  late final TextEditingController _stokCtrl;

  XFile? _imageFile;
  bool _isLoading = false;

  // ─── Monochrome Palette ───────────────────────────────────────
  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kCard    = Color(0xFF141414);
  static const kBorder  = Color(0xFF1E1E1E);
  static const kBorder2 = Color(0xFF2A2A2A);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);

  bool get _isUpdate => widget.item != null;

  @override
  void initState() {
    super.initState();
    // Jika mode update, isi form dengan data lama
    _namaCtrl     = TextEditingController(text: widget.item?.namaBarang ?? '');
    _deskripsiCtrl = TextEditingController(text: widget.item?.deskripsi ?? '');
    _hargaCtrl    = TextEditingController(text: widget.item?.harga.toString() ?? '');
    _stokCtrl     = TextEditingController(text: widget.item?.stok.toString() ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    super.dispose();
  }

  // ─── Pilih Foto dari Galeri ───────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() => _imageFile = picked);
    }
  }

  // ─── Simpan (Insert / Update) ─────────────────────────────────
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Insert baru wajib ada gambar
    if (!_isUpdate && _imageFile == null) {
      _showSnack("Pilih foto produk terlebih dahulu");
      return;
    }

    setState(() => _isLoading = true);

    final result = await _productService.insertProduct(
      id: widget.item?.id,
      namaBarang: _namaCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      harga: _hargaCtrl.text.trim(),
      stok: _stokCtrl.text.trim(),
      imageFile: _imageFile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.status) {
      _showSnack(_isUpdate ? "Produk berhasil diperbarui" : "Produk berhasil ditambahkan");
      Navigator.pop(context, true); // kirim sinyal refresh ke ProductView
    } else {
      _showSnack(result.message);
    }
  }

  // ─── Hapus Produk ─────────────────────────────────────────────
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorder2),
        ),
        title: Text(
          "Hapus Produk?",
          style: GoogleFonts.poppins(color: kWhite, fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Tindakan ini tidak dapat dibatalkan. Produk \"${widget.item?.namaBarang}\" akan dihapus permanen.",
          style: GoogleFonts.poppins(color: kGray1, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal",
                style: GoogleFonts.poppins(color: kGray2, fontSize: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus",
                style: GoogleFonts.poppins(
                  color: kWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                )),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);

    final result = await _productService.deleteProduct(widget.item!.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.status) {
      _showSnack("Produk berhasil dihapus");
      Navigator.pop(context, true);
    } else {
      _showSnack(result.message);
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

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildForm(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kWhite, size: 18),
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
            _isUpdate ? "EDIT PRODUK" : "TAMBAH PRODUK",
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: kGray2,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          Text(
            _isUpdate ? "Perbarui Data" : "Produk Baru",
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: kWhite,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
      actions: [
        // Tombol hapus hanya muncul di mode Update
        if (_isUpdate)
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: kGray1, size: 22),
            tooltip: "Hapus Produk",
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoading() {
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto Produk ──
            _buildImagePicker(),
            const SizedBox(height: 28),

            // ── Nama Barang ──
            _buildLabel("Nama Barang"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _namaCtrl,
              hint: "Contoh: Sepatu Olahraga",
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Nama barang wajib diisi" : null,
            ),
            const SizedBox(height: 18),

            // ── Deskripsi ──
            _buildLabel("Deskripsi"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _deskripsiCtrl,
              hint: "Deskripsi singkat produk...",
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Deskripsi wajib diisi" : null,
            ),
            const SizedBox(height: 18),

            // ── Harga & Stok ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Harga (Rp)"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _hargaCtrl,
                        hint: "50000",
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Wajib diisi";
                          if (int.tryParse(v) == null) return "Angka tidak valid";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Stok"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _stokCtrl,
                        hint: "100",
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Wajib diisi";
                          if (int.tryParse(v) == null) return "Angka tidak valid";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // ── Tombol Simpan ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kWhite,
                  foregroundColor: kBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isUpdate ? "Perbarui Produk" : "Simpan Produk",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Image Picker Widget ──────────────────────────────────────
  Widget _buildImagePicker() {
    final hasNewImage = _imageFile != null;
    final hasOldImage = _isUpdate && (widget.item?.image.isNotEmpty ?? false);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasNewImage ? kGray1 : kBorder2,
            width: hasNewImage ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasNewImage
            // Gambar baru dari galeri
            ? Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb
                      ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                      : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kBorder2),
                      ),
                      child: Text(
                        "Ganti Foto",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: kGray1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : hasOldImage
                // Gambar lama dari server (mode update)
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.item!.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image_outlined,
                                color: kGray2, size: 32)),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: kBorder2),
                          ),
                          child: Text(
                            "Ganti Foto",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: kGray1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                // Placeholder kosong (insert baru)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          color: kGray2, size: 36),
                      const SizedBox(height: 10),
                      Text(
                        "Pilih Foto Produk",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: kGray2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ketuk untuk membuka galeri",
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: kGray2.withOpacity(0.6)),
                      ),
                    ],
                  ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        color: kGray2,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: kWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: kGray2),
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorder2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorder2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kWhite, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGray2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGray2),
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 11, color: kGray1),
      ),
    );
  }

  static const kTextFieldSurface = Color(0xFF0F0F0F);
}