import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  List<QRHistoryItem> _historyItems = [];
  bool _isLoading = true;
  int _qrCodeSize = 200;
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
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
    _loadHistory();
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
                    child: _isLoading
                        ? _buildLoadingState()
                        : _historyItems.isEmpty
                            ? _buildEmptyState(isDark)
                            : _buildHistoryList(isDark),
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
                          '히스토리',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    '생성한 QR코드 ${_historyItems.length}개',
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
          if (_historyItems.isNotEmpty) _buildAnimatedActionButton(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: -0.3);
  }

  Widget _buildAnimatedActionButton(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF3B30),
                  const Color(0xFFFF6B6B),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showClearDialog();
                },
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF007AFF).withValues(alpha: 0.1),
                        const Color(0xFF5856D6).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    PhosphorIcons.clockCounterClockwise(),
                    size: 48,
                    color: const Color(0xFF007AFF),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            '아직 생성한 QR코드가 없어요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'QR코드를 생성하면 여기에 기록이 남아요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF98989D) : const Color(0xFF6D6D70),
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'QR코드 만들기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildHistoryList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 100),
      itemCount: _historyItems.length,
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        return _buildHistoryCard(item, index, isDark);
      },
    );
  }

  Widget _buildHistoryCard(QRHistoryItem item, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.mediumImpact();
            _showQRDetail(item, isDark);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _getGradientForType(item.type),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _getColorForType(item.type).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _getIconForType(item.type),
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
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1D1D1F),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.data.length > 30
                            ? '${item.data.substring(0, 30)}...'
                            : item.data,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF6D6D70),
                          letterSpacing: -0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorForType(item.type)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDate(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getColorForType(item.type),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, item),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            color:
                                isDark ? Colors.white : const Color(0xFF007AFF),
                          ),
                          const SizedBox(width: 12),
                          const Text('공유하기'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_rounded,
                              color: Color(0xFFFF3B30)),
                          const SizedBox(width: 12),
                          const Text(
                            '삭제하기',
                            style: TextStyle(color: Color(0xFFFF3B30)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: isDark
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF6D6D70),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2);
  }

  LinearGradient _getGradientForType(String type) {
    switch (type) {
      case '텍스트':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
        );
      case 'URL':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34C759), Color(0xFF248A3D)],
        );
      case 'WiFi':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9500), Color(0xFFFF6D00)],
        );
      case '연락처':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAF52DE), Color(0xFF8E44AD)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
        );
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case '텍스트':
        return const Color(0xFF007AFF);
      case 'URL':
        return const Color(0xFF34C759);
      case 'WiFi':
        return const Color(0xFFFF9500);
      case '연락처':
        return const Color(0xFFAF52DE);
      default:
        return const Color(0xFF007AFF);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case '텍스트':
        return PhosphorIcons.textT();
      case 'URL':
        return PhosphorIcons.globe();
      case 'WiFi':
        return PhosphorIcons.wifiHigh();
      case '연락처':
        return PhosphorIcons.addressBook();
      default:
        return PhosphorIcons.qrCode();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _qrCodeSize = prefs.getInt('default_qr_size') ?? 200;
    });
  }

  void _loadHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('qr_history') ?? '[]';
    final List<dynamic> historyList = json.decode(historyJson);

    setState(() {
      _historyItems = historyList
          .map((item) => QRHistoryItem.fromJson(item))
          .toList()
          .reversed
          .toList();
      _isLoading = false;
    });
  }

  void _showQRDetail(QRHistoryItem item, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _getGradientForType(item.type),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _getColorForType(item.type)
                                    .withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconForType(item.type),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.type,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1D1D1F),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatFullDate(item.createdAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF8E8E93)
                                      : const Color(0xFF6D6D70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF38383A)
                              : const Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: _qrCodeSize.toDouble(),
                          height: _qrCodeSize.toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: item.data,
                              version: QrVersions.auto,
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(int.parse('0xff${item.color}')),
                              ),
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(int.parse('0xff${item.color}')),
                              ),
                              backgroundColor: Colors.white,
                              errorStateBuilder: (cxt, err) {
                                return const Center(
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
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '데이터',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF38383A)
                              : const Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: SelectableText(
                                item.data,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                                  letterSpacing: -0.1,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (item.data.length > 100) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 16,
                                      color: const Color(0xFF007AFF),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '텍스트 복사 가능',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF007AFF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF007AFF).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _shareQRCode(item);
                          },
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.share_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '공유',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, QRHistoryItem item) {
    switch (action) {
      case 'share':
        _shareQRCode(item);
        break;
      case 'delete':
        _deleteHistoryItem(item);
        break;
    }
  }

  void _deleteHistoryItem(QRHistoryItem item) async {
    setState(() {
      _historyItems.removeWhere((historyItem) => historyItem.id == item.id);
    });

    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        json.encode(_historyItems.map((item) => item.toJson()).toList());
    await prefs.setString('qr_history', historyJson);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('히스토리에서 삭제되었습니다')),
      );
    }
  }

  void _showClearDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF3B30),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '모든 히스토리를 삭제하시겠습니까?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '저장된 모든 QR코드 기록이 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF6D6D70),
                      height: 1.4,
                      letterSpacing: -0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            _clearAllHistory();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '삭제',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF007AFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ).animate().scale(
            duration: 250.ms,
            curve: Curves.easeOutBack,
          ).fadeIn(
            duration: 200.ms,
          ),
        ),
      ),
    );
  }

  void _clearAllHistory() async {
    setState(() {
      _historyItems.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qr_history');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 히스토리가 삭제되었습니다')),
      );
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


  Future<void> _shareQRCode(QRHistoryItem item) async {
    try {
      HapticFeedback.lightImpact();
      debugPrint('공유 시작: 히스토리에서');

      // QR 데이터 유효성 검사
      if (item.data.isEmpty) {
        throw Exception('QR코드 데이터가 비어있습니다');
      }

      // QR 코드 이미지 생성
      final qrPainter = QrPainter(
        data: item.data,
        version: QrVersions.auto,
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(int.parse('0xff${item.color}')),
        ),
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(int.parse('0xff${item.color}')),
        ),
        gapless: true,
      );

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const size = 1024.0; // iOS에서 더 큰 이미지 사용

      // 흰색 배경 그리기
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, size, size),
        Paint()..color = Colors.white,
      );

      // QR 코드 그리기 (여백 없이)
      qrPainter.paint(canvas, const Size(size, size));

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
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
        text: 'CodeSlice에서 생성한 ${item.type} QR코드\n\n${item.data}',
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
            _showSuccessSnackBar(context, 'QR코드가 성공적으로 공유되었습니다');
            break;
          case ShareResultStatus.dismissed:
            debugPrint('사용자가 공유를 취소했습니다');
            break;
          case ShareResultStatus.unavailable:
            _showErrorSnackBar(context, '이 기기에서는 공유 기능을 사용할 수 없습니다');
            break;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('공유 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');

      if (mounted) {
        String errorMessage = '공유 중 오류가 발생했습니다';
        final errorString = e.toString().toLowerCase();

        if (errorString.contains('파일') || errorString.contains('file')) {
          errorMessage = '파일 생성에 실패했습니다. 저장 공간을 확인해주세요.';
        } else if (errorString.contains('permission') || errorString.contains('권한')) {
          errorMessage = '파일 접근 권한이 필요합니다. 설정을 확인해주세요.';
        } else if (errorString.contains('network') ||
            errorString.contains('연결')) {
          errorMessage = '네트워크 오류가 발생했습니다';
        } else if (errorString.contains('color') ||
            errorString.contains('색상')) {
          errorMessage = 'QR코드 색상 설정에 문제가 있습니다';
        } else if (errorString.contains('data') ||
            errorString.contains('데이터')) {
          errorMessage = 'QR코드 데이터에 문제가 있습니다';
        }

        _showErrorSnackBar(context, errorMessage);
      }
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
