import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online/services/user.dart';
import 'package:toko_online/widgets/alert.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final UserService _user = UserService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _showPass = false;

  static const kBg = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kBorder = Color(0xFF1E1E1E);
  static const kBorder2 = Color(0xFF2A2A2A);
  static const kWhite = Color(0xFFFFFFFF);
  static const kGray1 = Color(0xFFAAAAAA);
  static const kGray2 = Color(0xFF555555);

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _user.loginUser({
      "email": _email.text.trim(),
      "password": _password.text,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.status) {
      AlertMessage.showAlert(context, result.message, true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      });
    } else {
      AlertMessage.showAlert(context, result.message, false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // ── Brand ──
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: kBg,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "IntDex",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: kWhite,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // ── Heading ──
                  Text(
                    "Masuk ke\nAkunmu",
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      color: kWhite,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Kelola film dan pesanan dengan mudah",
                    style: GoogleFonts.poppins(fontSize: 13, color: kGray1),
                  ),

                  const SizedBox(height: 40),

                  // ── Form ──
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInput(
                          controller: _email,
                          label: "Email",
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Email harus diisi"
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _buildInput(
                          controller: _password,
                          label: "Password",
                          icon: Icons.lock_outline_rounded,
                          obscure: _showPass,
                          suffix: IconButton(
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: kGray2,
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _showPass = !_showPass),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Password harus diisi"
                              : null,
                        ),
                        const SizedBox(height: 28),

                        // ── Login Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kBg,
                                    ),
                                  )
                                : Text(
                                    "MASUK",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Register Link ──
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: RichText(
                        text: TextSpan(
                          style:
                              GoogleFonts.poppins(fontSize: 13, color: kGray1),
                          children: [
                            const TextSpan(text: "Belum punya akun? "),
                            TextSpan(
                              text: "Daftar",
                              style: GoogleFonts.poppins(
                                color: kWhite,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: kWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: kWhite, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: kGray2),
        suffixIcon: suffix,
        labelStyle: GoogleFonts.poppins(color: kGray2, fontSize: 13),
        floatingLabelStyle: GoogleFonts.poppins(color: kGray1, fontSize: 12),
      ),
    );
  }
}
