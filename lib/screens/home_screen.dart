import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'qr_generator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<QRType> _qrTypes = [
    QRType(
      icon: PhosphorIcons.textT(),
      title: '텍스트',
      subtitle: 'Messages & Notes',
      color: const Color(0xFF007AFF),
      emoji: '📝',
      description: 'Create QR codes from any text',
    ),
    QRType(
      icon: PhosphorIcons.globe(),
      title: 'URL',
      subtitle: 'Links & Websites',
      color: const Color(0xFF34C759),
      emoji: '🌐',
      description: 'Share websites and URLs',
    ),
    QRType(
      icon: PhosphorIcons.wifiHigh(),
      title: 'WiFi',
      subtitle: 'Network Access',
      color: const Color(0xFFFF9500),
      emoji: '📶',
      description: 'Quick WiFi connection',
    ),
    QRType(
      icon: PhosphorIcons.addressBook(),
      title: '연락처',
      subtitle: 'Contact Info',
      color: const Color(0xFF5856D6),
      emoji: '👤',
      description: 'Share contact details',
    ),
  ];


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(isDark, safeAreaBottom),
          HistoryScreen(key: ValueKey(_selectedIndex == 1 ? DateTime.now().millisecondsSinceEpoch : 0)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }


  Widget _buildHomeContent(bool isDark, double safeAreaBottom) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 32),
            _buildQuickActions(isDark),
            const SizedBox(height: 32),
            _buildQRTypesGrid(isDark),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF007AFF),
                    Color(0xFF5856D6),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CodeSlice',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'QR코드 생성기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(
          '어떤 QR코드를 만들까요?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '다양한 형태의 QR코드를 빠르고 간편하게 생성하세요',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
            height: 1.4,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }


  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 접근',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickActionCard(
          title: '히스토리',
          subtitle: '최근 생성한 QR코드 보기',
          icon: Icons.history_rounded,
          color: const Color(0xFF1F8959),
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
            HapticFeedback.selectionClick();
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRTypesGrid(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QR코드 생성',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: _qrTypes.length,
          itemBuilder: (context, index) {
            return _buildQRCard(_qrTypes[index], isDark);
          },
        ),
      ],
    );
  }

  Widget _buildQRCard(QRType qrType, bool isDark) {
    return Container(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRGeneratorScreen(
                  qrType: qrType.title,
                  color: qrType.color,
                  gradient: LinearGradient(
                    colors: [qrType.color, qrType.color],
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: qrType.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: qrType.color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        qrType.icon,
                        color: qrType.color,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      qrType.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  qrType.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  qrType.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: qrType.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: qrType.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '생성하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: qrType.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, '홈', isDark),
              _buildNavItem(1, Icons.history_outlined, Icons.history_rounded, '히스토리', isDark),
              _buildNavItem(2, Icons.settings_outlined, Icons.settings_rounded, '설정', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label, bool isDark) {
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF0969DA)
                    : isDark
                        ? const Color(0xFF8B949E)
                        : const Color(0xFF656D76),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF0969DA)
                      : isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFF656D76),
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
  final String emoji;
  final String description;

  QRType({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.emoji,
    required this.description,
  });
}
