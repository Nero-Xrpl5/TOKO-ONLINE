import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class PesanView extends StatefulWidget {
  const PesanView({super.key});

  @override
  State<PesanView> createState() => _PesanViewState();
}

class _PesanViewState extends State<PesanView> {
  static const kBg      = Color(0xFF000000);
  static const kCard    = Color(0xFF111111);
  static const kBorder  = Color(0xFF1A1A1A);
  static const kBorder2 = Color(0xFF262626);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);

  String _formatRupiah(int amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: kGray1),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "RIWAYAT",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: kGray2,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            Text(
              "Pesanan",
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: kWhite,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: 4,
        separatorBuilder: (_, __) => Container(height: 1, color: kBorder),
        itemBuilder: (_, i) => _buildOrderItem(i),
      ),
      bottomNavigationBar: const BottomNav(1),
    );
  }

  Widget _buildOrderItem(int i) {
    final isSelesai = i % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#INV-${202300 + i}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: kGray1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              _buildStatusBadge(isSelesai ? "SELESAI" : "PENDING", isSelesai),
            ],
          ),
          const SizedBox(height: 14),

          // Content row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  "https://picsum.photos/seed/order$i/80/80",
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(width: 56, height: 56, color: kCard),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Paket Bundle Film Premium",
                      style: GoogleFonts.poppins(
                        color: kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "3 item",
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: kGray2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatRupiah(150000),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: kWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, bool isSuccess) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          color: isSuccess ? kGray1 : kGray2,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}