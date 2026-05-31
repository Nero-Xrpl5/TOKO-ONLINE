import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online/services/user.dart';
import 'package:toko_online/widgets/alert.dart';

class RegisterUserView extends StatefulWidget {
  const RegisterUserView({super.key});

  @override
  State<RegisterUserView> createState() => _RegisterUserViewState();
}

class _RegisterUserViewState extends State<RegisterUserView> {
  final UserService _user = UserService();
  final _formKey = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _address  = TextEditingController();
  final _birthday = TextEditingController();
  final List<String> _roles = ["admin", "kasir"];
  String? _role;
  bool _showPass = false;
  bool _isLoading = false;

  static const kBg      = Color(0xFF000000);
  static const kSurface = Color(0xFF0F0F0F);
  static const kBorder  = Color(0xFF1E1E1E);
  static const kWhite   = Color(0xFFFFFFFF);
  static const kGray1   = Color(0xFFAAAAAA);
  static const kGray2   = Color(0xFF555555);

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kWhite,
            onPrimary: kBg,
            surface: Color(0xFF111111),
          ),
          dialogBackgroundColor: const Color(0xFF111111),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      const months = [
        "Januari","Februari","Maret","April","Mei","Juni",
        "Juli","Agustus","September","Oktober","November","Desember"
      ];
      setState(() {
        _birthday.text = "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _user.registerUser({
      "name":     _name.text.trim(),
      "email":    _email.text.trim(),
      "role":     _role!,
      "password": _password.text,
      "address":  _address.text.trim(),
      "birthday": _birthday.text,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.status) {
      AlertMessage.showAlert(context, result.message, true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      AlertMessage.showAlert(context, result.message, false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose();
    _address.dispose(); _birthday.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kGray1),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Heading ──
              Text(
                "Buat\nAkun Baru",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  color: kWhite,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Daftarkan dirimu untuk mulai mengelola",
                style: GoogleFonts.poppins(fontSize: 13, color: kGray1),
              ),

              const SizedBox(height: 36),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(
                      controller: _name,
                      label: "Nama Lengkap",
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.isEmpty) ? "Nama harus diisi" : null,
                    ),
                    const SizedBox(height: 14),
                    _buildInput(
                      controller: _email,
                      label: "Email",
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty) ? "Email harus diisi" : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Role Dropdown ──
                    DropdownButtonFormField<String>(
                      value: _role,
                      dropdownColor: const Color(0xFF111111),
                      style: GoogleFonts.poppins(color: kWhite, fontSize: 14),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kGray2),
                      decoration: InputDecoration(
                        labelText: "Role",
                        prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: kGray2),
                        labelStyle: GoogleFonts.poppins(color: kGray2, fontSize: 13),
                        floatingLabelStyle: GoogleFonts.poppins(color: kGray1, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F0F0F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF222222)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF222222)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kWhite, width: 1),
                        ),
                      ),
                      items: _roles.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: kWhite,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _role = v),
                      hint: Text("Pilih role",
                        style: GoogleFonts.poppins(color: kGray2, fontSize: 13)),
                      validator: (v) => v == null ? "Role harus dipilih" : null,
                    ),

                    const SizedBox(height: 14),
                    _buildInput(
                      controller: _password,
                      label: "Password",
                      icon: Icons.lock_outline_rounded,
                      obscure: _showPass,
                      suffix: IconButton(
                        icon: Icon(
                          _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: kGray2,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Password harus diisi" : null,
                    ),
                    const SizedBox(height: 14),
                    _buildInput(
                      controller: _address,
                      label: "Alamat",
                      icon: Icons.location_on_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? "Alamat harus diisi" : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Birthday ──
                    TextFormField(
                      controller: _birthday,
                      readOnly: true,
                      onTap: _selectDate,
                      style: GoogleFonts.poppins(color: kWhite, fontSize: 14),
                      validator: (v) => (v == null || v.isEmpty) ? "Tanggal lahir harus dipilih" : null,
                      decoration: InputDecoration(
                        labelText: "Tanggal Lahir",
                        prefixIcon: const Icon(Icons.cake_outlined, size: 18, color: kGray2),
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: kGray2),
                        labelStyle: GoogleFonts.poppins(color: kGray2, fontSize: 13),
                        floatingLabelStyle: GoogleFonts.poppins(color: kGray1, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F0F0F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF222222)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF222222)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kWhite, width: 1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Register Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: kBg),
                              )
                            : Text(
                                "DAFTAR SEKARANG",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(fontSize: 13, color: kGray1),
                      children: [
                        const TextSpan(text: "Sudah punya akun? "),
                        TextSpan(
                          text: "Masuk",
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
              const SizedBox(height: 32),
            ],
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
        filled: true,
        fillColor: const Color(0xFF0F0F0F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF222222)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF222222)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kWhite, width: 1),
        ),
      ),
    );
  }
}