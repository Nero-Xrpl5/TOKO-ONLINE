import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  UserLogin userLogin = UserLogin();
  String? nama;
  String? role;
  String? userEmail;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // ─── Monochrome Palette ───────────────────────────────────────
  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kCard    = Color(0xFF111111);
  static const kCard2   = Color(0xFF161616);
  static const kBorder  = Color(0xFF1A1A1A);
  static const kBorder2 = Color(0xFF262626);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF666666);
  static const kGray3   = Color(0xFF333333);

  final List<String> _carouselImages = [
    "https://picsum.photos/seed/cx1/800/400",
    "https://picsum.photos/seed/cx2/800/400",
    "https://picsum.photos/seed/cx3/800/400",
  ];

  @override
  void initState() {
    super.initState();
    _getUserLogin();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _carouselImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getUserLogin() async {
    final user = await userLogin.getUserLogin();
    if (user != null && mounted) {
      setState(() {
        nama      = user.nama_user;
        role      = user.role;
        userEmail = user.email;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorder2),
        ),
        title: Text(
          "Keluar Aplikasi?",
          style: GoogleFonts.poppins(color: kWhite, fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Apakah kamu yakin ingin keluar dari sesi ini?",
          style: GoogleFonts.poppins(color: kGray1, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal",
              style: GoogleFonts.poppins(color: kGray2, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Keluar",
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
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorder2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder2, width: 1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    nama?.substring(0, 1).toUpperCase() ?? "U",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: kWhite,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nama ?? "User",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: kWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  role?.toUpperCase() ?? "GUEST",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: kGray1,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: kBorder),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.alternate_email_rounded, size: 16, color: kGray2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userEmail ?? "-",
                      style: GoogleFonts.poppins(fontSize: 13, color: kGray1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBorder2),
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Tutup",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: role == "admin" ? _buildAdminView() : _buildKasirView(),
      bottomNavigationBar: BottomNav(0),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: kBg, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            "CINEMAX",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: kWhite,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: _showProfileDialog,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              border: Border.all(color: kBorder2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                nama?.substring(0, 1).toUpperCase() ?? "U",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: kWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout_rounded, color: kGray2, size: 20),
          tooltip: "Keluar",
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ══════════════════════════════════════════════
  //                  ADMIN VIEW
  // ══════════════════════════════════════════════
  Widget _buildAdminView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 40,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            "Selamat datang,",
            style: GoogleFonts.poppins(fontSize: 13, color: kGray2),
          ),
          Text(
            nama ?? "Admin",
            style: GoogleFonts.poppins(
              fontSize: 28,
              color: kWhite,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          _buildRoleBadge(),
          const SizedBox(height: 32),

          // ── Stat Label ──
          Text(
            "RINGKASAN",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: kGray2,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // ── Stats Grid ──
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard("Pendapatan",   "Rp 45.2 Jt", "+12%"),
              _buildStatCard("Total User",   "8,540",      "+5.4%"),
              _buildStatCard("Film Aktif",   "1,250",      "+2"),
              _buildStatCard("Pengaduan",    "12",         "-2"),
            ],
          ),

          const SizedBox(height: 32),

          // ── Recent Activity ──
          Text(
            "AKTIVITAS",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: kGray2,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildActivity("Baru saja",   "User Budi mendaftar Premium"),
          _buildActivity("5 menit lalu","Admin menghapus film 'Spiderman 3'"),
          _buildActivity("1 jam lalu",  "Server maintenance selesai"),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role?.toUpperCase() ?? "GUEST",
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: kGray1,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 11, color: kGray2),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: kWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                change,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: kGray1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivity(String time, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 2, right: 14),
            decoration: const BoxDecoration(
              color: kGray2,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 13, color: kWhite),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(fontSize: 11, color: kGray2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //                  KASIR VIEW
  // ══════════════════════════════════════════════
  Widget _buildKasirView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: kToolbarHeight + 30),

          // Greeting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo,",
                  style: GoogleFonts.poppins(fontSize: 13, color: kGray2),
                ),
                Text(
                  nama ?? "Kasir",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: kWhite,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                _buildRoleBadge(),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Carousel ──
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _carouselImages.length,
              itemBuilder: (_, i) => _buildCarouselItem(i),
            ),
          ),

          // Dots
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_carouselImages.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 2,
                width: active ? 20 : 6,
                decoration: BoxDecoration(
                  color: active ? kWhite : kGray3,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // ── Categories ──
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "GENRE",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: kGray2,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 6,
              itemBuilder: (_, i) {
                final cats = ["Semua", "Aksi", "Horor", "Sci-Fi", "Romance", "Animasi"];
                final active = i == 0;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: active ? kWhite : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: active ? kWhite : kBorder2),
                  ),
                  child: Center(
                    child: Text(
                      cats[i],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: active ? kBg : kGray1,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ── Now Playing ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SEDANG TAYANG",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: kGray2,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Semua →",
                  style: GoogleFonts.poppins(fontSize: 11, color: kGray1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (_, i) => _buildMovieCard(i),
            ),
          ),

          const SizedBox(height: 28),

          // ── Recommendations ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "REKOMENDASI",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: kGray2,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (_, i) => _buildRecoCard(i),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(int i) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _carouselImages[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: kCard),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              "Sedang Tren di CinemaX",
              style: GoogleFonts.poppins(
                color: kWhite,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(int i) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "https://picsum.photos/seed/playing$i/150/220",
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(color: kCard),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            "Film ${i + 1}",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: kWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Aksi",
            style: GoogleFonts.poppins(fontSize: 10, color: kGray2),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoCard(int i) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
              child: Image.network(
                "https://picsum.photos/seed/reco$i/300/400",
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(color: kCard2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Film ${i + 1}",
                  style: GoogleFonts.poppins(
                    color: kWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Genre",
                  style: GoogleFonts.poppins(color: kGray2, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}