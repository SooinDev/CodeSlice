import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with SingleTickerProviderStateMixin {
  List<QRHistoryItem> _historyItems = [];
  bool _isLoading = true;
  int _qrCodeSize = 200;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  String? _selectedItemId;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(isDark)
            : _historyItems.isEmpty
                ? _buildEmptyState(isDark)
                : _buildHistoryList(isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        '히스토리',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
        ),
      ),
      actions: [
        if (_historyItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showClearDialog();
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                    width: 1,
                  ),
                ),
                minimumSize: const Size(40, 40),
              ),
            ),
          ),
      ],
    );
  }



  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF007AFF) : const Color(0xFF007AFF),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '히스토리를 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                    ? const Color(0xFF007AFF).withValues(alpha: 0.2)
                    : const Color(0xFF007AFF).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                PhosphorIcons.clockCounterClockwise(),
                size: 48,
                color: const Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '아직 생성한 QR코드가 없어요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'QR코드를 생성하면 여기에 기록이 표시됩니다.\n언제든지 다시 찾아볼 수 있어요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                height: 1.5,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('첫 QR코드 만들기'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Text(
                '총 ${_historyItems.length}개',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: _historyItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _historyItems[index];
              return _buildHistoryCard(item, index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(QRHistoryItem item, int index, bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF21262D) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.mediumImpact();
                _showSelectionFeedback(item.id);
                _showQRDetail(item, isDark);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColorForType(item.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getColorForType(item.type).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getIconForType(item.type),
                        color: _getColorForType(item.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getColorForType(item.type).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getColorForType(item.type).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item.type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getColorForType(item.type),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(item.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (item.name != null && item.name!.isNotEmpty) ...[
                            Text(
                              item.name!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            item.data.length > 60
                                ? '${item.data.substring(0, 60)}...'
                                : item.data,
                            style: TextStyle(
                              fontSize: item.name != null && item.name!.isNotEmpty ? 13 : 14,
                              fontWeight: item.name != null && item.name!.isNotEmpty ? FontWeight.w400 : FontWeight.w500,
                              color: item.name != null && item.name!.isNotEmpty
                                  ? (isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76))
                                  : (isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F)),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, item),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share_rounded,
                                size: 16,
                                color: const Color(0xFF0969DA),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '공유하기',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.delete_rounded,
                                size: 16,
                                color: Color(0xFFDA3633),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '삭제하기',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFDA3633),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_selectedItemId == item.id)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      (MediaQuery.of(context).size.height * 0.1) * _slideAnimation.value,
                    ),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getColorForType(item.type).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getColorForType(item.type).withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getColorForType(item.type).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${item.type} 선택됨',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
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
        return const Color(0xFF5856D6);
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

  void _showSelectionFeedback(String itemId) {
    setState(() {
      _selectedItemId = itemId;
    });

    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _selectedItemId = null;
              });
            }
          });
        }
      });
    });
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
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1117) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: isDark ? const Color(0xFF21262D) : const Color(0xFFD0D7DE),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getColorForType(item.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getColorForType(item.type).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _getIconForType(item.type),
                            color: _getColorForType(item.type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.name != null && item.name!.isNotEmpty) ...[
                                Text(
                                  item.name!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getColorForType(item.type).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getColorForType(item.type).withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    item.type,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getColorForType(item.type),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  item.type,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                _formatFullDate(item.createdAt),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: _qrCodeSize.toDouble(),
                          height: _qrCodeSize.toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
                                        size: 24,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '오류가 발생했습니다',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
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
                    const SizedBox(height: 20),
                    Text(
                      '데이터',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 160),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          item.data,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _shareQRCode(item);
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('공유하기'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0969DA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFDA3633).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDA3633).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDA3633),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '히스토리 삭제',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
              ),
            ),
          ],
        ),
        content: Text(
          '모든 QR코드 기록이 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              _clearAllHistory();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDA3633),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('삭제'),
          ),
        ],
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
  final String? name;

  QRHistoryItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.color,
    this.name,
  });

  factory QRHistoryItem.fromJson(Map<String, dynamic> json) {
    return QRHistoryItem(
      id: json['id'],
      type: json['type'],
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      color: json['color'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
      'name': name,
    };
  }
}
