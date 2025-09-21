import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  bool _isDarkMode = false;
  bool _isHapticEnabled = true;
  bool _isAutoSave = false;
  int _defaultQRSize = 200;
  late AnimationController _floatingController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            _buildAnimatedBackground(isDark),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 100),
                      children: [
                        _buildAppearanceSection(isDark),
                        const SizedBox(height: 24),
                        _buildQRSettingsSection(isDark),
                        const SizedBox(height: 24),
                        _buildAboutSection(isDark),
                        const SizedBox(height: 24),
                        _buildDangerZoneSection(isDark),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.3 + math.sin(_backgroundController.value * 2 * math.pi) * 0.2,
                -0.2 +
                    math.cos(_backgroundController.value * 2 * math.pi) * 0.1,
              ),
              radius: 1.5,
              colors: isDark
                  ? [
                      const Color(0xFF000000),
                      const Color(0xFF0A0A0A),
                      const Color(0xFF000000),
                    ]
                  : [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFFFFFFF),
                      const Color(0xFFF0F0F5),
                    ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              ...List.generate(6, (index) {
                return AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    final offset = _floatingController.value * 2 * math.pi;
                    final x =
                        0.2 + index * 0.15 + math.sin(offset + index) * 0.1;
                    final y = 0.1 +
                        index * 0.12 +
                        math.cos(offset + index * 0.7) * 0.05;

                    return Positioned(
                      left: MediaQuery.of(context).size.width * x,
                      top: MediaQuery.of(context).size.height * y,
                      child: Container(
                        width: 100 + index * 20,
                        height: 100 + index * 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF007AFF)
                                  .withValues(alpha: isDark ? 0.1 : 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_breathingController.value * 0.02),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF007AFF),
                            const Color(0xFF5856D6),
                            const Color(0xFFAF52DE),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          '설정',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF007AFF).withValues(alpha: 0.1),
                        const Color(0xFF5856D6).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '앱 설정 및 개인화 옵션',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF007AFF),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildAnimatedLogo(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: -0.3);
  }

  Widget _buildAnimatedLogo(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF007AFF),
                      const Color(0xFF5856D6),
                      const Color(0xFFAF52DE),
                    ],
                    transform: GradientRotation(
                        _rotationController.value * 2 * math.pi),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF5856D6).withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppearanceSection(bool isDark) {
    return _buildSection(
      title: '화면 설정',
      icon: PhosphorIcons.palette(),
      isDark: isDark,
      children: [
        _buildSwitchTile(
          title: '다크 모드',
          subtitle: '어두운 테마 사용',
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
            _saveSettings();
          },
          icon: PhosphorIcons.moon(),
          isDark: isDark,
        ),
        _buildSwitchTile(
          title: '햅틱 피드백',
          subtitle: '버튼 터치 시 진동',
          value: _isHapticEnabled,
          onChanged: (value) {
            setState(() {
              _isHapticEnabled = value;
            });
            _saveSettings();
            if (value) {
              HapticFeedback.lightImpact();
            }
          },
          icon: PhosphorIcons.vibrate(),
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildQRSettingsSection(bool isDark) {
    return _buildSection(
      title: 'QR코드 설정',
      icon: PhosphorIcons.qrCode(),
      isDark: isDark,
      children: [
        _buildSwitchTile(
          title: '자동 저장',
          subtitle: '생성 시 갤러리에 자동 저장',
          value: _isAutoSave,
          onChanged: (value) {
            setState(() {
              _isAutoSave = value;
            });
            _saveSettings();
          },
          icon: PhosphorIcons.downloadSimple(),
          isDark: isDark,
        ),
        _buildSliderTile(
          title: '기본 QR코드 크기',
          subtitle: '${_defaultQRSize}px',
          value: _defaultQRSize.toDouble(),
          min: 150,
          max: 300,
          divisions: 5,
          onChanged: (value) {
            setState(() {
              _defaultQRSize = value.round();
            });
            _saveSettings();
          },
          icon: PhosphorIcons.resize(),
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildAboutSection(bool isDark) {
    return _buildSection(
      title: '앱 정보',
      icon: PhosphorIcons.info(),
      isDark: isDark,
      children: [
        _buildTile(
          title: '버전',
          subtitle: '1.0.0',
          onTap: null,
          icon: PhosphorIcons.tag(),
          isDark: isDark,
        ),
        _buildTile(
          title: '개발자',
          subtitle: 'QR Maker Team',
          onTap: null,
          icon: PhosphorIcons.user(),
          isDark: isDark,
        ),
        _buildTile(
          title: '피드백 보내기',
          subtitle: '의견이나 버그 신고',
          onTap: _sendFeedback,
          icon: PhosphorIcons.chatText(),
          showArrow: true,
          isDark: isDark,
        ),
        _buildTile(
          title: '평점 남기기',
          subtitle: '앱스토어에서 평가하기',
          onTap: _rateApp,
          icon: PhosphorIcons.star(),
          showArrow: true,
          isDark: isDark,
        ),
        _buildTile(
          title: '개발자에게 커피 사주기',
          subtitle: '앱 개발을 응원해주세요',
          onTap: _buyMeCoffee,
          icon: PhosphorIcons.coffee(),
          showArrow: true,
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildDangerZoneSection(bool isDark) {
    return _buildSection(
      title: '위험 구역',
      icon: PhosphorIcons.warning(),
      color: const Color(0xFFFF3B30),
      isDark: isDark,
      children: [
        _buildTile(
          title: '모든 히스토리 삭제',
          subtitle: '저장된 모든 QR코드 기록 삭제',
          onTap: _showClearHistoryDialog,
          icon: PhosphorIcons.trash(),
          showArrow: true,
          isDestructive: true,
          isDark: isDark,
        ),
        _buildTile(
          title: '앱 데이터 초기화',
          subtitle: '모든 설정과 데이터 초기화',
          onTap: _showResetAppDialog,
          icon: PhosphorIcons.arrowClockwise(),
          showArrow: true,
          isDestructive: true,
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: color != null
                          ? [color, color.withValues(alpha: 0.8)]
                          : [const Color(0xFF007AFF), const Color(0xFF5856D6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (color ?? const Color(0xFF007AFF)).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(!value);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (value ? const Color(0xFF007AFF) : isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFF2F2F7)).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: value ? const Color(0xFF007AFF) : isDark
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF6D6D70),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF6D6D70),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: value,
                  onChanged: (newValue) {
                    HapticFeedback.lightImpact();
                    onChanged(newValue);
                  },
                  activeThumbColor: const Color(0xFF007AFF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF007AFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF007AFF),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF007AFF),
                inactiveTrackColor: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF2F2F7),
                thumbColor: const Color(0xFF007AFF),
                overlayColor: const Color(0xFF007AFF).withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                trackHeight: 6,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (newValue) {
                  HapticFeedback.lightImpact();
                  onChanged(newValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required IconData icon,
    required bool isDark,
    bool showArrow = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? const Color(0xFFFF3B30).withValues(alpha: 0.15)
                        : (isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? const Color(0xFFFF3B30)
                        : (isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF6D6D70)),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? const Color(0xFFFF3B30)
                              : (isDark ? Colors.white : const Color(0xFF1D1D1F)),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF6D6D70),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showArrow)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDestructive
                        ? const Color(0xFFFF3B30)
                        : (isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF6D6D70)),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _isHapticEnabled = prefs.getBool('haptic_enabled') ?? true;
      _isAutoSave = prefs.getBool('auto_save') ?? false;
      _defaultQRSize = prefs.getInt('default_qr_size') ?? 200;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('haptic_enabled', _isHapticEnabled);
    await prefs.setBool('auto_save', _isAutoSave);
    await prefs.setInt('default_qr_size', _defaultQRSize);
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'feedback@qrcraft.app',
      queryParameters: {
        'subject': 'QR Maker 피드백',
        'body': '안녕하세요! QR Maker에 대한 피드백을 보내드립니다.\n\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showInfoDialog('메일 앱을 찾을 수 없습니다', '메일 앱이 설치되어 있는지 확인해주세요.');
    }
  }

  void _rateApp() async {
    _showInfoDialog('평점 남기기', 'App Store에서 QR Maker를 검색하여 평점을 남겨주세요!');
  }

  void _buyMeCoffee() async {
    _showInfoDialog('감사합니다! ☕', '개발자를 응원해주셔서 감사합니다!\n앞으로도 더 좋은 앱으로 보답하겠습니다.');
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('모든 히스토리 삭제'),
        content: const Text('정말로 모든 QR코드 히스토리를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showResetAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('앱 데이터 초기화'),
        content: const Text('모든 설정과 히스토리가 삭제됩니다.\n정말로 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAppData();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qr_history');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 히스토리가 삭제되었습니다')),
      );
    }
  }

  void _resetAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _isDarkMode = false;
      _isHapticEnabled = true;
      _isAutoSave = false;
      _defaultQRSize = 200;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앱 데이터가 초기화되었습니다')),
      );
    }
  }
}