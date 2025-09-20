import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'qr_generator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatingController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _breathingController;

  final List<QRType> _qrTypes = [
    QRType(
      icon: PhosphorIcons.textT(),
      title: '텍스트',
      subtitle: 'Messages & Notes',
      color: const Color(0xFF007AFF),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
        stops: [0.0, 1.0],
      ),
      emoji: '📝',
      description: 'Create QR codes from any text',
    ),
    QRType(
      icon: PhosphorIcons.globe(),
      title: 'URL',
      subtitle: 'Links & Websites',
      color: const Color(0xFF34C759),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF34C759), Color(0xFF248A3D)],
        stops: [0.0, 1.0],
      ),
      emoji: '🌐',
      description: 'Share websites and URLs',
    ),
    QRType(
      icon: PhosphorIcons.wifiHigh(),
      title: 'WiFi',
      subtitle: 'Network Access',
      color: const Color(0xFFFF9500),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF9500), Color(0xFFFF6D00)],
        stops: [0.0, 1.0],
      ),
      emoji: '📶',
      description: 'Quick WiFi connection',
    ),
    QRType(
      icon: PhosphorIcons.addressBook(),
      title: '연락처',
      subtitle: 'Contact Info',
      color: const Color(0xFFAF52DE),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFAF52DE), Color(0xFF8E44AD)],
        stops: [0.0, 1.0],
      ),
      emoji: '👤',
      description: 'Share contact details',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

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
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeContent(
                      isDark, screenHeight, safeAreaTop, safeAreaBottom),
                  HistoryScreen(key: ValueKey(_selectedIndex == 1 ? DateTime.now().millisecondsSinceEpoch : 0)),
                  const SettingsScreen(),
                ],
              ),
            ),
            _buildFloatingNavBar(isDark, safeAreaBottom),
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
                              _qrTypes[index % _qrTypes.length]
                                  .color
                                  .withValues(alpha:isDark ? 0.1 : 0.05),
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

  Widget _buildHomeContent(bool isDark, double screenHeight, double safeAreaTop,
      double safeAreaBottom) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 네비게이션 바 높이 (60) + 마진 (20*2) + safe area bottom
        final navBarTotalHeight = 60 + 40 + safeAreaBottom;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumHeader(isDark),
              const SizedBox(height: 32),
              _buildQuickActions(isDark),
              const SizedBox(height: 24),
              _buildQRTypesGrid(isDark),
              SizedBox(height: navBarTotalHeight + 20), // 네비게이션 바 공간 + 추가 여백
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                              'QR Maker',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha:0.1),
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
                            const Color(0xFF007AFF).withValues(alpha:0.1),
                            const Color(0xFF5856D6).withValues(alpha:0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF007AFF).withValues(alpha:0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Professional QR Generator',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha:0.9)
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
          const SizedBox(height: 32),
          Text(
            '오늘은 어떤 QR코드를\n만들어볼까요?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '빠르고 간편하게 다양한 형태의 QR코드를 생성하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF98989D) : const Color(0xFF6D6D70),
              letterSpacing: -0.1,
            ),
          ),
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
                      color: const Color(0xFF007AFF).withValues(alpha:0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF5856D6).withValues(alpha:0.2),
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
                        Icons.qr_code_2_rounded,
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
                              Colors.white.withValues(alpha:0.2),
                              Colors.transparent,
                              Colors.black.withValues(alpha:0.1),
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

  Widget _buildQuickActions(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Scan QR',
                  subtitle: 'Camera scanner',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF007AFF),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Implement QR scanner
                  },
                  isDark: isDark,
                  isSmallScreen: MediaQuery.of(context).size.width < 375,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Recent',
                  subtitle: 'History view',
                  icon: Icons.history_rounded,
                  color: const Color(0xFF34C759),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    HapticFeedback.selectionClick();
                  },
                  isDark: isDark,
                  isSmallScreen: MediaQuery.of(context).size.width < 375,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideX(begin: -0.2);
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha:0.8)
            : Colors.white.withValues(alpha:0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF1D1D1F),
                            letterSpacing: -0.2,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 1 : 2),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF8E8E93)
                                : const Color(0xFF6D6D70),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildQRTypesGrid(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create QR Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = MediaQuery.of(context).size.width < 375;
              final aspectRatio = isSmallScreen ? 0.58 : 0.63;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: isSmallScreen ? 12 : 16,
                  mainAxisSpacing: isSmallScreen ? 12 : 16,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: _qrTypes.length,
                itemBuilder: (context, index) {
                  return _buildPremiumQRCard(
                      _qrTypes[index], index, isDark, isSmallScreen);
                },
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildPremiumQRCard(
      QRType qrType, int index, bool isDark, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha:0.8)
            : Colors.white.withValues(alpha:0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDark ? 0.4 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: qrType.color.withValues(alpha:0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, _) => QRGeneratorScreen(
                  qrType: qrType.title,
                  color: qrType.color,
                  gradient: qrType.gradient,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  var offsetAnimation = animation.drive(tween);
                  var scaleAnimation =
                      Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: curve),
                  );

                  return SlideTransition(
                    position: offsetAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 375 ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: qrType.gradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: qrType.color.withValues(alpha:0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              qrType.icon,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha:0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: qrType.color.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          qrType.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.width < 375 ? 8 : 12),
                Text(
                  qrType.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  qrType.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF6D6D70),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  qrType.description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFF636366)
                        : const Color(0xFF8E8E93),
                    letterSpacing: -0.05,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        qrType.color.withValues(alpha:0.15),
                        qrType.color.withValues(alpha:0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: qrType.color.withValues(alpha:0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Generate',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: qrType.color,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: qrType.color,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (index * 150).ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.4)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildFloatingNavBar(bool isDark, double safeAreaBottom) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20 + safeAreaBottom,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withValues(alpha:0.95)
              : Colors.white.withValues(alpha:0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.05),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:isDark ? 0.6 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha:isDark ? 0.2 : 0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.house_rounded, 'Home', isDark),
                _buildNavItem(1, Icons.history_rounded, 'History', isDark),
                _buildNavItem(2, Icons.settings_rounded, 'Settings', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: isSelected ? 36 : 32,
                height: isSelected ? 36 : 32,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(isSelected ? 12 : 10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withValues(alpha:0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: isSelected ? 18 : 16,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF6D6D70),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 9 : 8,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF6D6D70),
                    letterSpacing: -0.1,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRType {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final LinearGradient gradient;
  final String emoji;
  final String description;

  QRType({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
    required this.emoji,
    required this.description,
  });
}
