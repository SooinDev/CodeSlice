# 🎨 CodeSlice - 아름다운 QR 코드 생성기

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" />
</div>

<br />

<div align="center">
  <p><strong>빠르고 간편하게 다양한 형태의 QR코드를 생성하세요</strong></p>
  <p>프리미엄 디자인과 부드러운 애니메이션으로 완성된 QR 코드 메이커</p>
</div>

## ✨ 주요 기능

### 🎯 QR 코드 생성 타입
- **📝 텍스트** - 메시지 및 노트를 QR코드로 변환
- **🌐 URL** - 웹사이트 링크 공유
- **📶 WiFi** - 빠른 WiFi 연결을 위한 QR코드
- **👤 연락처** - 연락처 정보 공유

### 🎨 디자인 & 사용자 경험
- **Material 3** 디자인 시스템 적용
- **다크/라이트 모드** 자동 지원
- **부드러운 애니메이션** - Flutter Animate 사용
- **아름다운 그라디언트** 및 색상 테마
- **직관적인 네비게이션** - 플로팅 내비게이션 바

### 📱 편의 기능
- **히스토리 관리** - 생성한 QR코드 기록 저장
- **공유 기능** - Share Plus로 간편한 공유
- **컬러 피커** - 사용자 정의 색상 선택
- **로컬 저장소** - SharedPreferences로 설정 저장

## 🛠️ 기술 스택

### 핵심 프레임워크
- **Flutter** `>=3.2.0 <4.0.0` - 크로스 플랫폼 개발
- **Dart** - 프로그래밍 언어

### 주요 패키지
```yaml
dependencies:
  # QR 코드 생성
  qr_flutter: ^4.1.0

  # UI & 애니메이션
  flutter_animate: ^4.2.0+1      # 부드러운 애니메이션
  lottie: ^2.7.0                 # 로티 애니메이션
  flex_color_scheme: ^8.3.0      # 색상 테마 관리
  flutter_colorpicker: ^1.0.3    # 컬러 피커
  phosphor_flutter: ^2.0.0       # 아이콘

  # 기능
  share_plus: ^7.2.1             # 공유 기능
  path_provider: ^2.1.1          # 파일 시스템 접근
  shared_preferences: ^2.2.2     # 로컬 저장소
  url_launcher: ^6.2.1           # URL 실행
```

## 🚀 시작하기

### 사전 요구사항
- Flutter SDK `3.2.0` 이상
- Dart SDK
- Android Studio / VS Code
- Android/iOS 개발 환경

### 설치 및 실행

1. **저장소 클론**
```bash
git clone https://github.com/your-username/qr_maker.git
cd qr_maker
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **앱 실행**
```bash
flutter run
```

### 빌드

**Android APK 빌드**
```bash
flutter build apk --release
```

**iOS 빌드**
```bash
flutter build ios --release
```

## 📱 스크린샷

> 아름다운 UI와 직관적인 사용자 경험을 제공합니다

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점 및 테마 설정
├── screens/
│   ├── home_screen.dart      # 홈 화면 (QR 타입 선택)
│   ├── qr_generator_screen.dart  # QR 코드 생성 화면
│   ├── history_screen.dart   # 히스토리 화면
│   └── settings_screen.dart  # 설정 화면
└── assets/
    ├── images/              # 이미지 리소스
    ├── animations/          # 로티 애니메이션
    └── icons/              # 커스텀 아이콘
```

## 🎨 디자인 특징

### 색상 팔레트
- **Primary**: `#007AFF` (iOS Blue)
- **Secondary**: `#5856D6` (iOS Purple)
- **Accent**: `#AF52DE` (iOS Violet)
- **Success**: `#34C759` (iOS Green)
- **Warning**: `#FF9500` (iOS Orange)

### 애니메이션
- **Floating** - 4초 주기 반복 애니메이션
- **Pulse** - 3초 주기 펄스 효과
- **Breathing** - 2초 주기 호흡 효과
- **Rotation** - 20초 주기 회전 애니메이션

## 🔧 커스터마이징

### 테마 변경
`main.dart`에서 FlexColorScheme을 수정하여 테마를 변경할 수 있습니다:

```dart
theme: FlexThemeData.light(
  scheme: FlexScheme.indigo,  // 여기서 색상 스키마 변경
  // ...
),
```

### QR 타입 추가
`home_screen.dart`의 `_qrTypes` 리스트에 새로운 QRType을 추가할 수 있습니다.

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 연락처

프로젝트 관련 문의나 제안사항이 있으시면 언제든지 연락주세요!

---

<div align="center">
  <p>⭐ 이 프로젝트가 유용하다면 스타를 눌러주세요!</p>
  <p>Made with ❤️ and Flutter</p>
</div>