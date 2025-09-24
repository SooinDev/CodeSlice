import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isHapticEnabled = true;
  int _defaultQRSize = 200;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFFAFBFC),
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAppearanceSection(isDark),
            const SizedBox(height: 16),
            _buildQRSettingsSection(isDark),
            const SizedBox(height: 16),
            _buildAboutSection(isDark),
            const SizedBox(height: 16),
            _buildDangerZoneSection(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFFAFBFC),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0969DA).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF0969DA).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.settings_outlined,
                  size: 16,
                  color: Color(0xFF0969DA),
                ),
                const SizedBox(width: 6),
                const Text(
                  '설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0969DA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          onChanged: (value) async {
            setState(() {
              _isDarkMode = value;
            });
            _saveSettings();

            // 햅틱 피드백 추가
            if (_isHapticEnabled) {
              HapticFeedback.mediumImpact();
            }

            // ThemeNotifier를 통해 전체 앱 테마 변경
            Provider.of<ThemeNotifier>(context, listen: false).setTheme(value);
          },
          icon: _isDarkMode ? PhosphorIcons.moon() : PhosphorIcons.sun(),
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
    );
  }

  Widget _buildQRSettingsSection(bool isDark) {
    return _buildSection(
      title: 'QR코드 설정',
      icon: PhosphorIcons.qrCode(),
      isDark: isDark,
      children: [
        _buildSliderTile(
          title: '기본 QR코드 크기',
          subtitle: '${_defaultQRSize}px',
          value: _defaultQRSize.toDouble(),
          min: 150,
          max: 300,
          divisions: 10,
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
    );
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
          subtitle: 'SooinDev',
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
    );
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
    );
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
        color: isDark ? const Color(0xFF21262D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (color ?? const Color(0xFF0969DA)).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (color ?? const Color(0xFF0969DA)).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? const Color(0xFF0969DA),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (value ? const Color(0xFF0969DA) : (isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA))).withValues(alpha: value ? 0.1 : 1.0),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? const Color(0xFF0969DA).withValues(alpha: 0.2) : (isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFF0969DA) : (isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76)),
              size: 16,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeThumbColor: const Color(0xFF0969DA),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0969DA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF0969DA).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0969DA),
                  size: 16,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0969DA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF0969DA),
              inactiveTrackColor: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
              thumbColor: const Color(0xFF0969DA),
              overlayColor: const Color(0xFF0969DA).withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? const Color(0xFFDA3633).withValues(alpha: 0.1)
                        : (isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDestructive
                          ? const Color(0xFFDA3633).withValues(alpha: 0.2)
                          : (isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? const Color(0xFFDA3633)
                        : (isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76)),
                    size: 16,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? const Color(0xFFDA3633)
                              : (isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showArrow)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDestructive
                        ? const Color(0xFFDA3633)
                        : (isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76)),
                    size: 16,
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
      _defaultQRSize = prefs.getInt('default_qr_size') ?? 200;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('haptic_enabled', _isHapticEnabled);
    await prefs.setInt('default_qr_size', _defaultQRSize);
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'feedback@qrcraft.app',
      queryParameters: {
        'subject': 'CodeSlice 피드백',
        'body': '안녕하세요! CodeSlice에 대한 피드백을 보내드립니다.\n\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showInfoDialog('메일 앱을 찾을 수 없습니다', '메일 앱이 설치되어 있는지 확인해주세요.');
    }
  }

  void _rateApp() async {
    _showInfoDialog('평점 남기기', 'App Store에서 CodeSlice를 검색하여 평점을 남겨주세요!');
  }

  void _buyMeCoffee() async {
    _showInfoDialog('감사합니다! ☕', '개발자를 응원해주셔서 감사합니다!\n앞으로도 더 좋은 앱으로 보답하겠습니다.');
  }

  void _showClearHistoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
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

  void _showResetAppDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
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
                Icons.refresh_rounded,
                color: Color(0xFFDA3633),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '앱 데이터 초기화',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
              ),
            ),
          ],
        ),
        content: Text(
          '모든 설정과 히스토리가 삭제됩니다. 정말로 계속하시겠습니까?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
              _resetAppData();
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
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
            width: 1,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
            height: 1.4,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0969DA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
      _defaultQRSize = 200;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앱 데이터가 초기화되었습니다')),
      );
    }
  }
}
