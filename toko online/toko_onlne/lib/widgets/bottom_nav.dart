import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online/models/user_login.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  UserLogin userLogin = UserLogin();
  String? role;

  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0D0D0D);
  static const kBorder  = Color(0xFF1A1A1A);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray    = Color(0xFF555555);

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await userLogin.getUserLogin();
    if (mounted) {
      setState(() => role = user?.role ?? "kasir");
    }
  }

  void _navigate(int index) {
    if (role == "admin") {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      if (index == 1) Navigator.pushReplacementNamed(context, '/movie');
    } else {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      if (index == 1) Navigator.pushReplacementNamed(context, '/pesan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kBorder, width: 1)),
      ),
      child: Row(
        children: [
          _buildItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: "Beranda",
            index: 0,
          ),
          _buildItem(
            icon: role == "admin"
                ? Icons.movie_outlined
                : Icons.receipt_long_outlined,
            activeIcon: role == "admin"
                ? Icons.movie_rounded
                : Icons.receipt_long_rounded,
            label: role == "admin" ? "Film" : "Pesanan",
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = widget.activePage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigate(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? kWhite : kGray,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isActive ? kWhite : kGray,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}