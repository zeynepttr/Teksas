import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _show2FA = false;
  String? _errorMessage;
  int _countdown = 30;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _countdownTimer?.cancel();
          }
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await FirebaseService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted && user != null) {
        // SMS/Email gönderim simülasyonu
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _isLoading = false;
          _show2FA = true;
        });
        _startCountdown();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerify2FA() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen 6 haneli doğrulama kodunu giriniz."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simüle doğrulanma gecikmesi
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _show2FA
                  ? _build2FAForm()
                  : Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Brand Logo Image
                          Container(
                            width: 160,
                            height: 160,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/logo2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Welcome slogan
                          const Text(
                            "Hane'nize Hoşgeldiniz!",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.oliveGreen,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Error Box if there is an error
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error, width: 0.5),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Email Input
                          CustomTextField(
                            controller: _emailController,
                            hintText: "eposta@hane.org.tr",
                            labelText: "E-posta Adresi",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Lütfen e-posta adresinizi giriniz.";
                              }
                              if (!val.contains("@")) {
                                return "Geçersiz e-posta formatı.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          CustomTextField(
                            controller: _passwordController,
                            hintText: "••••••",
                            labelText: "Şifre",
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Lütfen şifrenizi giriniz.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          CustomButton(
                            text: "Giriş Yap",
                            width: double.infinity,
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 32),

                          // Quick test credentials help text
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceLight, width: 1),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hızlı Giriş Bilgileri:",
                                  style: TextStyle(
                                    fontFamily: 'DINPro',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "• İHH Çalışanı: employee@hane.org.tr\n• İK Admin: admin@hane.org.tr\n• Şifre (ortak): hane1234",
                                  style: TextStyle(
                                    fontFamily: 'DINPro',
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build2FAForm() {
    String email = _emailController.text.trim();
    String obfuscatedEmail = "";
    if (email.contains("@")) {
      final parts = email.split("@");
      final name = parts[0];
      final domain = parts[1];
      if (name.length > 2) {
        obfuscatedEmail = "${name.substring(0, 2)}••••@$domain";
      } else {
        obfuscatedEmail = "••@$domain";
      }
    } else {
      obfuscatedEmail = "eposta@hane.org.tr";
    }

    return Column(
      key: const ValueKey("2FA_Section"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppColors.accent,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          "İki Adımlı Doğrulama",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.oliveGreen,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          "Güvenliğiniz için $obfuscatedEmail adresine gönderilen 6 haneli doğrulama kodunu giriniz.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DINPro',
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        CustomTextField(
          controller: _codeController,
          hintText: "Örn: 123456",
          labelText: "Doğrulama Kodu",
          prefixIcon: Icons.lock_open_outlined,
          keyboardType: TextInputType.number,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "Lütfen doğrulama kodunu giriniz.";
            }
            if (val.trim().length != 6) {
              return "Kod 6 haneli olmalıdır.";
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        CustomButton(
          text: "Doğrula ve Giriş Yap",
          width: double.infinity,
          isLoading: _isLoading,
          onPressed: _handleVerify2FA,
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _show2FA = false;
                  _codeController.clear();
                  _countdownTimer?.cancel();
                });
              },
              child: const Text(
                "Geri Dön",
                style: TextStyle(fontFamily: 'DINPro', color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: _countdown == 0
                  ? () {
                      _startCountdown();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Yeni doğrulama kodu e-posta adresinize gönderildi."),
                          backgroundColor: AppColors.buttonDark,
                        ),
                      );
                    }
                  : null,
              child: Text(
                _countdown > 0 ? "Kodu Tekrar Gönder ($_countdown sn)" : "Kodu Tekrar Gönder",
                style: TextStyle(
                  fontFamily: 'DINPro',
                  color: _countdown > 0 ? AppColors.textMuted : AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
