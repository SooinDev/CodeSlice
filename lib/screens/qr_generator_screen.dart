import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
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

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _wifiNameController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey _qrKey = GlobalKey();
  String _qrData = '';
  Color _selectedColor = const Color(0xFF6366F1);
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.qrType} QR코드'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_qrData.isNotEmpty)
            IconButton(
              onPressed: _shareQR,
              icon: const Icon(Icons.share),
            ),
          if (_qrData.isNotEmpty)
            IconButton(
              onPressed: _saveQR,
              icon: const Icon(Icons.download),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 32),
            _buildColorSelector(),
            const SizedBox(height: 32),
            _buildQRCodeSection(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            '정보 입력',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInputFields(),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildInputFields() {
    switch (widget.qrType) {
      case '텍스트':
        return TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: '텍스트 입력',
            hintText: 'QR코드로 만들 텍스트를 입력하세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (_) => _updateQRData(),
        );

      case 'URL':
        return TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'URL 입력',
            hintText: 'https://example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => _updateQRData(),
        );

      case 'WiFi':
        return Column(
          children: [
            TextField(
              controller: _wifiNameController,
              decoration: const InputDecoration(
                labelText: 'WiFi 이름 (SSID)',
                hintText: 'WiFi 네트워크 이름',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              onChanged: (_) => _updateQRData(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wifiPasswordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                hintText: 'WiFi 비밀번호',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              onChanged: (_) => _updateQRData(),
            ),
          ],
        );

      case '연락처':
        return Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '연락처 이름',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (_) => _updateQRData(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '010-1234-5678',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (_) => _updateQRData(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: 'example@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => _updateQRData(),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildColorSelector() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'QR코드 색상',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              ).animate().scale(
                    duration: 200.ms,
                    curve: Curves.easeInOut,
                  );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Text(
            'QR코드 미리보기',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _selectedColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _qrData.isNotEmpty
                ? RepaintBoundary(
                    key: _qrKey,
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 200,
                      foregroundColor: _selectedColor,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          child: const Center(
                            child: Text(
                              '오류가 발생했습니다',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '정보를 입력하면\nQR코드가 생성됩니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildGenerateButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _qrData.isNotEmpty ? _generateQR : null,
          child: Center(
            child: _isGenerating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'QR코드 생성하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  void _updateQRData() {
    String data = '';

    switch (widget.qrType) {
      case '텍스트':
        data = _textController.text;
        break;

      case 'URL':
        data = _urlController.text;
        break;

      case 'WiFi':
        if (_wifiNameController.text.isNotEmpty) {
          data =
              'WIFI:T:WPA;S:${_wifiNameController.text};P:${_wifiPasswordController.text};;';
        }
        break;

      case '연락처':
        if (_nameController.text.isNotEmpty ||
            _phoneController.text.isNotEmpty) {
          data = 'BEGIN:VCARD\n'
              'VERSION:3.0\n'
              'FN:${_nameController.text}\n'
              'TEL:${_phoneController.text}\n'
              'EMAIL:${_emailController.text}\n'
              'END:VCARD';
        }
        break;
    }

    setState(() {
      _qrData = data;
    });
  }

  void _generateQR() async {
    if (_qrData.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    await _saveToHistory();

    setState(() {
      _isGenerating = false;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR코드가 생성되고 히스토리에 저장되었습니다!'),
        backgroundColor: widget.color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareQR() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'QR코드 공유');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공유 중 오류가 발생했습니다')),
      );
    }
  }

  void _saveQR() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(pngBytes);

      await GallerySaver.saveImage(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('갤러리에 저장되었습니다!'),
          backgroundColor: widget.color,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 오류가 발생했습니다')),
      );
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
        color: _selectedColor.value.toRadixString(16),
      );

      historyList.add(historyItem.toJson());

      if (historyList.length > 100) {
        historyList.removeAt(0);
      }

      await prefs.setString('qr_history', json.encode(historyList));
    } catch (e) {
      print('히스토리 저장 오류: $e');
    }
  }

  String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
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
