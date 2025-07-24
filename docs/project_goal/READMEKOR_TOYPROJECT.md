# MY PAGE 알 키우기 데모 (로컬 버전)

이 프로젝트는 '실패/실수 회고'라는 다소 진입 장벽이 높은 행동을 '알 키우기' 게임 요소를 통해 사용자의 심리적 부담을 낮추고 꾸준한 참여를 유도하기 위한 데모 애플리케이션입니다. Firebase와 같은 백엔드 서비스 없이, Flutter의 Riverpod를 활용하여 모든 데이터와 상태를 로컬 메모리에서 관리하는 버전입니다. 이 코드는 다음 주에 진행될 MY PAGE 작업의 **스켈레톤(뼈대) 코드**로 활용될 예정입니다.

## 1. 프로젝트 목표

* **핵심 목표:** 사용자가 일기/회고 작성을 통해 자신의 실패와 실수를 분석하고 개선 계획을 수립하는 행동 습관을 형성하도록 돕습니다.

* **게임 요소의 역할:** '알 키우기'를 통해 회고 작성에 대한 심리적 부담을 낮추고, 펫의 성장과 시각적 보상을 통해 꾸준한 기록 동기를 부여합니다.

## 2. 프로젝트 구조

```
lib/
├── main.dart             # 앱의 진입점 및 전역 테마 설정
├── models/
│   ├── pet.dart          # 펫 데이터 모델 정의
│   └── reflection.dart   # 회고 기록 데이터 모델 정의
├── providers/
│   └── pet_notifier.dart # 펫 상태 및 회고 기록을 관리하는 Riverpod StateNotifier
└── screens/
    ├── my_page.dart      # 초기 MY PAGE 화면 (펫 이미지, 상태 바, 3가지 버튼)
    ├── clean_page.dart   # 'CLEAN' 액션 페이지 (출석체크)
    ├── play_page.dart    # 'PLAY' 액션 페이지 (일기 쓰기)
    ├── play_history_page.dart # 'PLAY'/'FEED' 기록 히스토리 페이지
    └── feed_page.dart    # 'FEED' 액션 페이지 (주제 회고)
```

## 3. 시작하기 (Getting Started)

### 3.1. 필수 조건

* Flutter SDK 설치 (https://flutter.dev/docs/get-started/install)

* 선호하는 IDE (VS Code, Android Studio 등)

### 3.2. 프로젝트 설정 및 실행

1. **프로젝트 클론 (또는 생성):**

   ```
   git clone [YOUR_REPOSITORY_URL] toy_project
   cd toy_project
   ```

   또는, 새 Flutter 프로젝트를 생성합니다:

   ```
   flutter create toy_project
   cd toy_project
   ```

2. **`pubspec.yaml` 업데이트:**
   프로젝트 루트의 `pubspec.yaml` 파일을 열어 다음 의존성을 추가합니다.

   ```
   dependencies:
     flutter:
       sdk: flutter
     flutter_riverpod: ^2.x.x
     table_calendar: ^3.0.9
     google_fonts: ^6.x.x
     uuid: ^4.x.x
   
   flutter:
     uses-material-design: true
     assets:
       - assets/images/ # 곽곽님이 준비하실 픽셀 아트 이미지 폴더 (필수)
     fonts:
       - family: PixelFont # 선택 사항: 픽셀 아트 폰트 사용 시
         fonts:
           - asset: assets/fonts/YourPixelFont.ttf # 폰트 파일 경로
   ```

3. **패키지 가져오기:**
   터미널에서 다음 명령어를 실행하여 패키지를 다운로드합니다.

   ```
   flutter pub get
   ```

4. **애셋 준비 (곽곽님 담당):**
   `assets/images/` 폴더를 생성하고, `egg_stage0.png`, `egg_stage1.png`, `egg_stage2.png`, `baby_pet.png`와 같은 픽셀 아트 이미지 파일을 이 폴더에 배치합니다. (SVG 파일을 사용하려면 `Image.asset`을 `flutter_svg` 패키지의 `SvgPicture.asset`으로 변경해야 합니다.)

5. **앱 실행:**
   시뮬레이터 또는 실제 기기를 연결한 후 다음 명령어로 앱을 실행합니다.

   ```
   flutter run
   ```

## 4. 사용된 주요 패키지

현재 스켈레톤 코드에서 활용되고 `pubspec.yaml`에 명시된 주요 패키지들은 다음과 같습니다. 이 패키지들은 Flutter의 기본 기능 외에 특정 기능을 구현하는 데 사용됩니다.

* **`flutter_riverpod`**: `^2.x.x`
    * **용도:** Flutter 애플리케이션의 상태 관리를 위한 프레임워크. 펫 상태 및 회고 기록 데이터를 앱 전역에서 효율적으로 관리하고 UI와 연동합니다.
* **`table_calendar`**: `^3.0.9`
    * **용도:** 'CLEAN' 페이지의 출석체크 기능에서 달력 UI를 구현합니다.
* **`google_fonts`**: `^6.x.x`
    * **용도:** Google Fonts를 Flutter 앱에 쉽게 적용합니다. 픽셀 아트 스타일에 어울리는 폰트 적용에 활용됩니다.
* **`uuid`**: `^4.x.x`
    * **용도:** 로컬에서 회고 기록(`Reflection`)과 같은 데이터에 고유한 ID를 생성합니다.

## 5. 팀원별 역할 및 다음 주 과제

이 코드는 다음 주 MY PAGE 작업을 위한 스켈레톤입니다. 각 팀원은 아래 내용을 바탕으로 깊이 고민하고 구현을 진행해야 합니다.

### 5.1. 곽곽 (UI/UX 권한 설계자 🎨)

* **주요 과제 및 향후 개선:**
    * **다양한 픽셀 아트 애셋 제작:** 현재 4단계 알/펫 이미지 외에, 더 많은 성장 단계(예: 성체 펫의 다양한 진화형), 펫의 감정 상태(행복, 슬픔, 배고픔 등)를 표현하는 표정/포즈, 펫 꾸미기 아이템(모자, 배경 등)의 픽셀 아트 디자인 및 제작이 필요합니다.
    * **세부 애니메이션 추가:** 펫의 성장 애니메이션 외에, `CLEAN`, `PLAY`, `FEED` 액션 시 펫이 반응하는 애니메이션(예: 청결 시 반짝임, 놀아줄 때 점프, 먹이 줄 때 행복한 표정)을 추가하여 사용자 상호작용의 만족도를 높여야 합니다.
    * **UI/UX 일관성 및 디테일:** 모든 모달, 버튼, 입력 필드, 상태 바 등 앱의 모든 UI 요소에 픽셀 아트 스타일을 일관되게 적용하고, 사용자 친화적인 레이아웃과 내비게이션을 설계해야 합니다.
* **현재 코드에서 활용된 부분:**
    * Flutter 기본 위젯(`Container`, `Column`, `Row`, `Image.asset`, `ElevatedButton` 등)을 활용한 UI 레이아웃의 기본 틀이 구현되어 있습니다.
    * `AnimatedSwitcher`를 이용한 펫 이미지 전환 애니메이션의 기본 구조가 마련되어 있습니다.
    * `ThemeData`를 통한 전역 폰트 및 UI 스타일 적용의 예시가 포함되어 있습니다.
        * 공식 FLutter 문서 - LAYOUT: https://docs.flutter.dev/ui/layout 
* **참고 자료:**
    * **Flutter UI 및 애니메이션 심화:**
        * 공식 Flutter 문서 - 애니메이션: https://docs.flutter.dev/ui/animations
    * **픽셀 아트 디자인 심화:**
        * 픽셀 아트 튜토리얼 (MortMort YouTube): https://www.youtube.com/playlist?list=PLR3g_Ew-rK_V0w22XN30kXy2q4iP_1wTz
        * Piskel 또는 Aseprite 사용법 (각 도구의 공식 문서/튜토리얼)
    * **SVG 이미지 사용 (`flutter_svg`):**
        * `flutter_svg` 패키지 문서: https://pub.dev/packages/flutter_svg

### 5.2. 예예 (접근 제어 시스템 설계자 🔐)

* **주요 과제 및 향후 개선:**
    * **실제 DB 모델링 및 규칙 설계:** 로컬 더미 데이터 대신 Firebase Firestore와 같은 실제 데이터베이스 연동을 위한 `users`, `pets`, `reflections` 컬렉션의 최종 데이터 모델을 설계하고, 관계형 데이터베이스의 스키마처럼 명확하게 정의해야 합니다.
    * **게임 로직 고도화:** 시간 경과에 따른 펫 상태(배고픔, 행복, 청결)의 자동 감소 로직(예: 타이머 기반), 특정 조건(예: 3일 연속 회고)에 따른 특별한 펫 진화 조건 또는 보너스 경험치 부여 로직 등을 추가해야 합니다.
    * **데이터 유효성 및 무결성:** 사용자 입력 데이터(회고 내용)의 최소/최대 길이 제한, 비속어 필터링, 데이터 형식 검증 등 데이터 유효성 검사 규칙을 정의해야 합니다.
* **현재 코드에서 활용된 부분:**
    * `lib/models/pet.dart`와 `lib/models/reflection.dart`에서 펫과 회고 기록의 기본적인 데이터 구조가 정의되어 있습니다.
    * `lib/providers/pet_notifier.dart` 내의 `PetNotifier` 클래스에서 경험치 획득 규칙, 성장 단계 변화 조건, 각 액션에 따른 펫 상태 변화 규칙, 출석체크의 일일 제한 로직 등 핵심 게임 로직의 초안이 구현되어 있습니다.
* **참고 자료:**
    * **Dart 언어 심화:**
        * Dart 공식 문서: https://dart.dev/guides
    * **게임 로직 설계 원칙:**
        * '게임 밸런싱', '진행 시스템', '보상 메커니즘' 관련 자료 (검색)
        * 상태 머신 (State Machine) 개념
    * **데이터베이스 모델링 (향후 Firebase 연동 시):**
        * Firebase Firestore 데이터 모델링 가이드: https://firebase.google.com/docs/firestore/data-model
        * Firestore Security Rules: https://firebase.google.com/docs/firestore/security/overview

### 5.3. 장장 (기능 및 상태 통합 담당자 🔗)

* **주요 과제 및 향후 개선:**
    * **실제 DB 연동 및 동기화:** 로컬 `StateNotifier` 대신 Firebase Firestore와 같은 실제 DB와 앱의 상태를 실시간으로 동기화하는 로직(데이터 로드, 저장, 업데이트, 삭제)을 구현해야 합니다.
    * **사용자 인증 시스템 구축:** 실제 사용자 관리를 위한 회원가입, 로그인(이메일/비밀번호, 소셜 로그인 등), 비밀번호 찾기 등의 인증 시스템(Firebase Authentication 등 활용)을 구현해야 합니다.
    * **배포 (DEPLOY) 전략 수립:** 개발된 앱을 실제 사용자들에게 제공하기 위한 모바일 앱 스토어(Google Play Store, Apple App Store) 배포 절차 및 웹 배포(Firebase Hosting 등) 전략을 수립해야 합니다.
    * **서비스 전체 연결 및 프로젝트 일정 관리 책임:** 각 팀원의 작업물을 통합하고, 전체 서비스의 기능이 유기적으로 연결되도록 조율하며, 프로젝트 일정 수립, 진척도 관리, 이슈 트래킹 등 PM 역할을 수행해야 합니다.
* **현재 코드에서 활용된 부분:**
    * `flutter_riverpod`의 `StateNotifierProvider`를 활용한 로컬 상태 관리 및 UI 업데이트 연동의 기본 구조가 구축되어 있습니다.
    * `Navigator`를 이용한 화면 간 이동 및 `ScaffoldMessenger`를 통한 사용자 피드백(`SnackBar`) 제공 로직이 포함되어 있습니다.
    * `uuid` 패키지를 이용한 고유 ID 생성 기능이 구현되어 있습니다.
* **참고 자료:**
    * **Riverpod 심화:**
        * Riverpod 공식 문서: https://riverpod.dev/
    * **Flutter 상태 관리 패턴:**
        * 공식 Flutter 문서 - 상태 관리: https://docs.flutter.dev/data-and-backend/state-mgmt/options
    * **데이터 영속성 (향후 구현 시):**
        * `shared_preferences` (키-값 데이터): https://pub.dev/packages/shared_preferences
        * `Hive` (NoSQL 로컬 DB): https://pub.dev/packages/hive
        * `sqflite` (SQLite 로컬 DB): https://pub.dev/packages/sqflite
    * **프로젝트 관리 및 협업 도구:**
        * Git/GitHub Flow (브랜치 전략, PR, 코드 리뷰)
        * 애자일 방법론 (스크럼, 칸반)

## 6. 향후 확장 및 개선 아이디어 (전체 프로젝트 관점)

* **사용자 인증:** 실제 서비스에서는 Firebase Authentication 등을 활용한 사용자 로그인/회원가입 기능을 추가해야 합니다.
* **데이터 영속성:** 로컬 저장소 또는 클라우드 데이터베이스(Firebase Firestore 등)를 연동하여 사용자 데이터를 영구적으로 저장하고 관리합니다.
* **펫 커스터마이징:** 펫의 이름 변경, 꾸미기 아이템 착용 등 사용자화 기능을 추가합니다.
* **추가 게임 요소:** 펫의 상태가 나빠지면 경고를 주거나, 펫과의 상호작용(쓰다듬기, 말 걸기)을 통해 행복도를 높이는 등의 요소를 추가합니다.
* **회고 기록 상세화:** 회고 기록에 감정 태그, 키워드 분석, 통계 그래프 등을 추가하여 자기 성찰을 돕습니다.
* **알림 기능:** 회고 작성 시간 알림, 펫 상태 알림 등 푸시 알림 기능을 추가하여 사용자 참여를 유도합니다.
