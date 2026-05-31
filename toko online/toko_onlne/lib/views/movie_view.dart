// ─────────────────────────────────────────────────────────────────────────────
// FILE: lib/views/movie_view.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class MovieView extends StatefulWidget {
  const MovieView({super.key});

  @override
  State<MovieView> createState() => _MovieViewState();
}

class _MovieViewState extends State<MovieView> {
  static const kBg      = Color(0xFF000000);
  static const kCard    = Color(0xFF111111);
  static const kBorder  = Color(0xFF1A1A1A);
  static const kBorder2 = Color(0xFF262626);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
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
              "KELOLA",
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
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 16, color: kBg),
              label: Text(
                "Tambah",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: kBg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: kWhite,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: 5,
        separatorBuilder: (_, __) => Container(height: 1, color: kBorder),
        itemBuilder: (_, i) => _buildMovieItem(i),
      ),
      bottomNavigationBar: const BottomNav(1),
    );
  }

  Widget _buildMovieItem(int i) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              "https://picsum.photos/seed/mov$i/100/140",
              width: 60,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 60, height: 85, color: kCard),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Spider-Man: No Way Home",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: kWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Aksi  •  2 Jam 28 Menit  •  2021",
                  style: GoogleFonts.poppins(fontSize: 11, color: kGray2),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "TERSEDIA",
                        style: GoogleFonts.poppins(
                          color: kGray1,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildIconBtn(Icons.edit_outlined, () {}),
                    const SizedBox(width: 4),
                    _buildIconBtn(Icons.delete_outline_rounded, () {}, danger: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: kBorder2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 15, color: danger ? const Color(0xFF888888) : kGray1),
      ),
    );
  }
}