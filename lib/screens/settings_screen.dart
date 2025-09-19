import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isHapticEnabled = true;
  bool _isAutoSave = false;
  int _defaultQRSize = 200;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildAppearanceSection(),
                  const SizedBox(height: 24),
                  _buildQRSettingsSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildDangerZoneSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '설정',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              const SizedBox(height: 4),
              Text(
                '앱 설정 및 개인화 옵션',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideX(begin: -0.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: '화면 설정',
      icon: Icons.palette_outlined,
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
          icon: Icons.dark_mode_outlined,
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
          icon: Icons.vibration,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildQRSettingsSection() {
    return _buildSection(
      title: 'QR코드 설정',
      icon: Icons.qr_code_2_outlined,
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
          icon: Icons.save_alt_outlined,
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
          icon: Icons.photo_size_select_large_outlined,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: '앱 정보',
      icon: Icons.info_outline,
      children: [
        _buildTile(
          title: '버전',
          subtitle: '1.0.0',
          onTap: null,
          icon: Icons.system_update_outlined,
        ),
        _buildTile(
          title: '개발자',
          subtitle: 'QR Craft Team',
          onTap: null,
          icon: Icons.person_outline,
        ),
        _buildTile(
          title: '피드백 보내기',
          subtitle: '의견이나 버그 신고',
          onTap: _sendFeedback,
          icon: Icons.feedback_outlined,
          showArrow: true,
        ),
        _buildTile(
          title: '평점 남기기',
          subtitle: '앱스토어에서 평가하기',
          onTap: _rateApp,
          icon: Icons.star_outline,
          showArrow: true,
        ),
        _buildTile(
          title: '개발자에게 커피 사주기',
          subtitle: '앱 개발을 응원해주세요',
          onTap: _buyMeCoffee,
          icon: Icons.local_cafe_outlined,
          showArrow: true,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildDangerZoneSection() {
    return _buildSection(
      title: '위험 구역',
      icon: Icons.warning_outlined,
      color: Theme.of(context).colorScheme.error,
      children: [
        _buildTile(
          title: '모든 히스토리 삭제',
          subtitle: '저장된 모든 QR코드 기록 삭제',
          onTap: _showClearHistoryDialog,
          icon: Icons.delete_forever_outlined,
          showArrow: true,
          isDestructive: true,
        ),
        _buildTile(
          title: '앱 데이터 초기화',
          subtitle: '모든 설정과 데이터 초기화',
          onTap: _showResetAppDialog,
          icon: Icons.restore_outlined,
          showArrow: true,
          isDestructive: true,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color ?? Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
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
  }) {
    return ListTile(
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
  }) {
    return Column(
      children: [
        ListTile(
          leading:
              Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          title: Text(title),
          subtitle: Text(subtitle),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required IconData icon,
    bool showArrow = false,
    bool isDestructive = false,
  }) {
    final textColor =
        isDestructive ? Theme.of(context).colorScheme.error : null;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: showArrow
          ? Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
        'subject': 'QR Craft 피드백',
        'body': '안녕하세요! QR Craft에 대한 피드백을 보내드립니다.\n\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showInfoDialog('메일 앱을 찾을 수 없습니다', '메일 앱이 설치되어 있는지 확인해주세요.');
    }
  }

  void _rateApp() async {
    _showInfoDialog('평점 남기기', 'App Store에서 QR Craft를 검색하여 평점을 남겨주세요!');
  }

  void _buyMeCoffee() async {
    _showInfoDialog('감사합니다! ☕', '개발자를 응원해주셔서 감사합니다!\n앞으로도 더 좋은 앱으로 보답하겠습니다.');
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qr_history');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 히스토리가 삭제되었습니다')),
    );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('앱 데이터가 초기화되었습니다')),
    );
  }
}
