import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class QRGeneratorScreen extends StatefulWidget {
  final String qrType;
  final Color color;
  final LinearGradient gradient;

  const QRGeneratorScreen({
    super.key,
    required this.qrType,
    required this.color,
    required this.gradient,
  });

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _wifiNameController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey _qrKey = GlobalKey();
  String _qrData = '';
  Color _selectedColor = const Color(0xFF007AFF);
  bool _isGenerating = false;
  double _qrSize = 220;

  late AnimationController _qrAnimationController;
  late AnimationController _colorAnimationController;

  final List<Color> _premiumColors = [
    const Color(0xFF007AFF),
    const Color(0xFF34C759),
    const Color(0xFFFF9500),
    const Color(0xFFAF52DE),
    const Color(0xFFFF3B30),
    const Color(0xFF5856D6),
    const Color(0xFF00C7BE),
    const Color(0xFFFF6B35),
    const Color(0xFF1D1D1F),
    const Color(0xFF8E8E93),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.color;
    _loadQRSize();
    _qrAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _qrAnimationController.dispose();
    _colorAnimationController.dispose();
    _textController.dispose();
    _urlController.dispose();
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: _buildPremiumAppBar(isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF000000),
                    const Color(0xFF111111),
                    const Color(0xFF000000),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF8F9FA),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTypeHeader(isDark),
                const SizedBox(height: 32),
                _buildPremiumInputSection(isDark),
                const SizedBox(height: 32),
                _buildPremiumColorSelector(isDark),
                const SizedBox(height: 32),
                _buildPremiumQRCodeSection(isDark),
                const SizedBox(height: 32),
                _buildPremiumGenerateButton(isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
              width: 0.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      actions: [
        if (_qrData.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _shareQR();
                },
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.share_rounded,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeHeader(bool isDark) {
    IconData iconData;
    switch (widget.qrType) {
      case '텍스트':
        iconData = Icons.text_fields_rounded;
        break;
      case 'URL':
        iconData = Icons.link_rounded;
        break;
      case 'WiFi':
        iconData = Icons.wifi_rounded;
        break;
      case '연락처':
        iconData = Icons.contact_page_rounded;
        break;
      default:
        iconData = Icons.qr_code_rounded;
    }

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            iconData,
            size: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.qrType} QR코드',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '정보를 입력하여 QR코드를 생성하세요',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF98989D)
                      : const Color(0xFF6D6D70),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildPremiumInputSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정보 입력',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildPremiumInputFields(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildPremiumInputFields(bool isDark) {
    switch (widget.qrType) {
      case '텍스트':
        return _buildPremiumTextField(
          controller: _textController,
          label: '텍스트 입력',
          hint: 'QR코드로 만들 텍스트를 입력하세요',
          icon: Icons.text_fields_rounded,
          maxLines: 4,
          isDark: isDark,
        );

      case 'URL':
        return _buildPremiumTextField(
          controller: _urlController,
          label: 'URL 입력',
          hint: 'https://example.com',
          icon: Icons.link_rounded,
          keyboardType: TextInputType.url,
          isDark: isDark,
        );

      case 'WiFi':
        return Column(
          children: [
            _buildPremiumTextField(
              controller: _wifiNameController,
              label: 'WiFi 네트워크 이름',
              hint: '네트워크 SSID',
              icon: Icons.wifi_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildPremiumTextField(
              controller: _wifiPasswordController,
              label: '비밀번호',
              hint: 'WiFi 비밀번호',
              icon: Icons.lock_rounded,
              obscureText: true,
              isDark: isDark,
            ),
          ],
        );

      case '연락처':
        return Column(
          children: [
            _buildPremiumTextField(
              controller: _nameController,
              label: '이름',
              hint: '연락처 이름',
              icon: Icons.person_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildPremiumTextField(
              controller: _phoneController,
              label: '전화번호',
              hint: '010-1234-5678',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildPremiumTextField(
              controller: _emailController,
              label: '이메일',
              hint: 'example@email.com',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C2C2E).withValues(alpha: 0.6)
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        onChanged: (_) => _updateQRData(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1D1D1F),
          letterSpacing: -0.1,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: isDark ? const Color(0xFF98989D) : const Color(0xFF6D6D70),
            size: 22,
          ),
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF98989D) : const Color(0xFF6D6D70),
            letterSpacing: -0.1,
          ),
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
            letterSpacing: -0.1,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumColorSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QR코드 색상',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: _premiumColors.length,
            itemBuilder: (context, index) {
              final color = _premiumColors[index];
              final isSelected = _selectedColor == color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  _colorAnimationController.forward().then((_) {
                    _colorAnimationController.reverse();
                  });
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 3,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: isSelected ? 0.4 : 0.2),
                        blurRadius: isSelected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: _getContrastColor(color),
                          size: 24,
                        )
                      : null,
                ),
              ).animate().scale(
                    duration: 200.ms,
                    curve: Curves.easeInOut,
                  );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildPremiumQRCodeSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'QR코드 미리보기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          if (_qrData.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QR코드 크기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '${_qrSize.round()}px',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedColor,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _selectedColor,
                inactiveTrackColor: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF2F2F7),
                thumbColor: _selectedColor,
                overlayColor: _selectedColor.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                trackHeight: 4,
              ),
              child: Slider(
                value: _qrSize,
                min: 150,
                max: 300,
                divisions: 5,
                onChanged: (value) {
                  setState(() {
                    _qrSize = value;
                  });
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          AnimatedBuilder(
            animation: _qrAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_qrAnimationController.value * 0.05),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedColor.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: _qrData.isNotEmpty
                      ? RepaintBoundary(
                          key: _qrKey,
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: _qrSize,
                            gapless: true,
                            semanticsLabel: 'QR Code',
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: _selectedColor,
                            ),
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: _selectedColor,
                            ),
                            backgroundColor: Colors.white,
                            errorStateBuilder: (cxt, err) {
                              return Container(
                                width: _qrSize,
                                height: _qrSize,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '오류가 발생했습니다',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: _qrSize,
                          height: _qrSize,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF48484A)
                                  : const Color(0xFFD1D1D6),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_rounded,
                                size: 48,
                                color: isDark
                                    ? const Color(0xFF636366)
                                    : const Color(0xFF8E8E93),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '정보를 입력하면\nQR코드가 생성됩니다',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF636366)
                                      : const Color(0xFF8E8E93),
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildPremiumGenerateButton(bool isDark) {
    final isEnabled = _qrData.isNotEmpty && !_isGenerating;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? widget.gradient
            : LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isEnabled ? _generateQR : null,
          child: Center(
            child: _isGenerating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'QR코드 생성하기',
                    style: TextStyle(
                      color: isEnabled ? Colors.white : Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3);
  }

  Color _getContrastColor(Color color) {
    double luminance = (0.299 * (color.r * 255) +
            0.587 * (color.g * 255) +
            0.114 * (color.b * 255)) /
        255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _updateQRData() {
    String data = '';

    switch (widget.qrType) {
      case '텍스트':
        data = _textController.text.trim();
        break;

      case 'URL':
        data = _urlController.text.trim();
        break;

      case 'WiFi':
        if (_wifiNameController.text.trim().isNotEmpty) {
          data =
              'WIFI:T:WPA;S:${_wifiNameController.text.trim()};P:${_wifiPasswordController.text.trim()};;';
        }
        break;

      case '연락처':
        if (_nameController.text.trim().isNotEmpty ||
            _phoneController.text.trim().isNotEmpty) {
          data = 'BEGIN:VCARD\n'
              'VERSION:3.0\n'
              'FN:${_nameController.text.trim()}\n'
              'TEL:${_phoneController.text.trim()}\n'
              'EMAIL:${_emailController.text.trim()}\n'
              'END:VCARD';
        }
        break;
    }

    if (_qrData != data) {
      setState(() {
        _qrData = data;
      });
    }
  }

  void _generateQR() async {
    if (_qrData.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    _qrAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 800));

    await _saveToHistory();

    setState(() {
      _isGenerating = false;
    });

    _qrAnimationController.reverse();

    HapticFeedback.heavyImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR코드가 생성되고 히스토리에 저장되었습니다!'),
          backgroundColor: widget.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareQR() async {
    try {
      HapticFeedback.lightImpact();
      debugPrint('공유 시작: QR 생성기에서');

      // QR코드 가 생성되었는지 확인
      if (_qrData.isEmpty) {
        throw Exception('QR코드가 생성되지 않았습니다');
      }

      // RenderRepaintBoundary를 사용하여 이미지 캡처
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('QR코드 렌더링 경계를 찾을 수 없습니다');
      }

      // iOS에서 더 높은 해상도로 캡처
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('이미지 데이터를 생성할 수 없습니다');
      }

      final pngBytes = byteData.buffer.asUint8List();
      debugPrint('이미지 데이터 크기: ${pngBytes.length} bytes');

      // iOS에서 더 안전한 파일 경로 사용
      final tempDir = await getTemporaryDirectory();
      final fileName = 'QRCode_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');

      // 파일 쓰기 전에 디렉토리 존재 확인
      await file.parent.create(recursive: true);
      await file.writeAsBytes(pngBytes, flush: true);

      // 파일 생성 확인
      if (!await file.exists()) {
        throw Exception('파일 생성에 실패했습니다');
      }

      final fileSize = await file.length();
      debugPrint('파일 생성 완료: ${file.path}, 크기: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('빈 파일이 생성되었습니다');
      }

      // iOS에서 공유 시 더 명확한 MIME 타입 지정
      final xFile = XFile(
        file.path,
        name: fileName,
        mimeType: 'image/png',
      );

      // 공유 실행
      debugPrint('공유 시작 중...');
      final result = await Share.shareXFiles(
        [xFile],
        text: 'CodeSlice에서 생성한 ${widget.qrType} QR코드\n\n$_qrData',
        subject: 'QR 코드 공유',
        sharePositionOrigin: mounted ?
          Rect.fromLTWH(
            MediaQuery.of(context).size.width / 2 - 50,
            MediaQuery.of(context).size.height / 2 - 50,
            100,
            100,
          ) : null,
      );

      debugPrint('공유 결과: ${result.status}');

      // 공유 완료 후 임시 파일 정리 (iOS에서 더 긴 지연)
      Future.delayed(const Duration(seconds: 10), () async {
        try {
          if (await file.exists()) {
            await file.delete();
            debugPrint('임시 파일 삭제 완료');
          }
        } catch (e) {
          debugPrint('파일 삭제 실패: $e');
        }
      });

      // 공유 결과에 따른 메시지 표시
      if (mounted) {
        switch (result.status) {
          case ShareResultStatus.success:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('QR코드가 성공적으로 공유되었습니다'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            break;
          case ShareResultStatus.dismissed:
            // 사용자가 취소한 경우 - 메시지 표시하지 않음
            break;
          case ShareResultStatus.unavailable:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text('공유 기능을 사용할 수 없습니다'),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            break;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('공유 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');

      if (mounted) {
        String errorMessage = '공유 중 오류가 발생했습니다';
        final errorString = e.toString().toLowerCase();

        if (errorString.contains('permission') || errorString.contains('권한')) {
          errorMessage = '파일 접근 권한이 필요합니다. 설정을 확인해주세요.';
        } else if (errorString.contains('파일') || errorString.contains('file')) {
          errorMessage = '파일 생성에 실패했습니다. 저장 공간을 확인해주세요.';
        } else if (errorString.contains('network') ||
            errorString.contains('연결')) {
          errorMessage = '네트워크 오류가 발생했습니다';
        } else if (errorString.contains('render') ||
            errorString.contains('렌더')) {
          errorMessage = 'QR코드 렌더링에 실패했습니다. 다시 시도해주세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('qr_history') ?? '[]';
      final List<dynamic> historyList = json.decode(historyJson);

      final historyItem = QRHistoryItem(
        id: _generateId(),
        type: widget.qrType,
        data: _qrData,
        createdAt: DateTime.now(),
        color: _selectedColor.toARGB32().toRadixString(16),
      );

      historyList.add(historyItem.toJson());

      if (historyList.length > 100) {
        historyList.removeRange(0, historyList.length - 100);
      }

      await prefs.setString('qr_history', json.encode(historyList));
    } catch (e) {
      debugPrint('히스토리 저장 오류: $e');
    }
  }

  String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void _loadQRSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSize = prefs.getDouble('default_qr_size') ?? prefs.getInt('default_qr_size')?.toDouble() ?? 220.0;
      if (mounted) {
        setState(() {
          _qrSize = savedSize;
        });
      }
    } catch (e) {
      debugPrint('Failed to load QR size preference: $e');
    }
  }
}

class QRHistoryItem {
  final String id;
  final String type;
  final String data;
  final DateTime createdAt;
  final String color;

  QRHistoryItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.color,
  });

  factory QRHistoryItem.fromJson(Map<String, dynamic> json) {
    return QRHistoryItem(
      id: json['id'],
      type: json['type'],
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
    };
  }
}
