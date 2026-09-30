# 색칠 놀이 (kids_coloring)

아이들을 위한 탭 색칠 게임. 색을 고르고 그림의 칸을 탭하면 칠해진다. Google Play **가족 정책**을 따르는 AdMob 광고(배너 / 보상형).
Flutter, Android + iOS. 한국어 · 영어 · 일본어 · 중국어(간체).
앱 이름: 색칠 놀이 / Coloring Fun / ぬりえあそび / 涂色乐园. applicationId `com.jun5731.kids_coloring`.

## 구조

```
lib/
  main.dart                     앱 진입, 밝은 테마 고정, 스크린샷용 LOCALE 강제
  l10n/strings.dart             문자열 en/ko/ja/zh (그림·팩 이름 포함) + LocaleController
  ads/ad_ids.dart               AdMob 광고 단위 ID (배너·보상형만)  ← 출시 전 교체
  ads/ad_manager.dart           아동 대상 설정(ageRestrictedTreatment.child, 등급 G) + 보상형 광고
  art/shapes.dart               도형 도우미 (원·타원·다각형·별·하트·무지개 띠, 1000x1000 좌표)
  art/pictures.dart             그림 16장 (팩 3개), 영역 목록 + 선 장식, regionAt() 탭 판정
  art/palette.dart              크레파스 18색
  services/storage.dart         SharedPreferences: 색칠 상태, 열린 팩, 언어
  services/coloring_store.dart  색칠 상태 ChangeNotifier (칠하기/지우기/완성/잠금 해제)
  widgets/picture_painter.dart  그림 렌더링 (영역별 채우기→테두리, 선 장식)
  widgets/parental_gate.dart    보호자 확인 (곱셈 6~9 x 6~9)
  widgets/banner_ad_widget.dart 하단 배너 (갤러리 화면에만)
  screens/gallery_screen.dart   그림 고르기 (팩별 격자, 잠긴 팩 열기)
  screens/coloring_screen.dart  색칠 (탭 채우기, 두 손가락 확대, 되돌리기, 처음부터, 완성 축하)
test/coloring_test.dart         그림 무결성(모든 칸 탭 가능), 이름 번역, 저장소 로직
test/preview_render_test.dart   그림 미리보기 PNG → build/previews/sheet.png
tool/make_icon.py               아이콘 원본 (무지개로 반쯤 칠한 별 + 크레파스)
docs/privacy-policy.html        아동용 개인정보처리방침 (GitHub Pages 용)
```

그림은 이미지 파일이 아니라 코드로 만든 벡터 경로다. 영역은 아래→위 순서로 쌓이고, 탭은 위쪽 영역부터 검사한다.
첫 영역은 항상 배경. 새 그림은 `pictures.dart` 에 추가하고 `flutter test` 로 "모든 칸이 탭 가능한지" 확인 +
`flutter test test/preview_render_test.dart` 로 모양을 눈으로 확인.

| 팩 | 그림 | 열기 |
|---|---|---|
| 0 처음 색칠 | 해님, 우리 집, 물고기, 꽃, 자동차, 고양이, 나무, 풍선 | 무료 |
| 1 신나는 모험 | 로켓, 돛단배, 눈사람, 무지개 | 보호자 확인 → 보상형 광고 |
| 2 동물 친구와 간식 | 나비, 거북이, 아이스크림, 하트와 별 | 보호자 확인 → 보상형 광고 |

## 광고 / 가족 정책

| 항목 | 처리 |
|---|---|
| 광고 요청 | `RequestConfiguration(ageRestrictedTreatment: child, maxAdContentRating: G)` — 비맞춤 광고만 |
| 광고 ID | 매니페스트에서 `com.google.android.gms.permission.AD_ID` 제거 |
| Privacy Sandbox | `ACCESS_ADSERVICES_AD_ID / ATTRIBUTION / TOPICS` 제거 |
| 배너 | 갤러리 화면에만. 색칠 화면에는 광고 없음 |
| 전면 광고 | 사용 안 함 |
| 보상형 | 보호자 확인 통과 + 안내 창에서 "광고 보기"를 눌렀을 때만 |

Play Console 에서 할 일: 타겟층에 13세 미만 포함 → 가족 정책 적용, 광고 SDK 는 Google AdMob(가족 인증 SDK),
AdMob 앱 설정에서도 "아동 대상" 처리 확인.

## 개발 빌드

```bash
flutter pub get
flutter test
flutter build apk --debug --target-platform android-x64
```

언어 확인: `--dart-define=LOCALE=ko` (디버그 전용).
이 PC 전용 설정(AGP 9 / Gradle 9.3, `-Djdk.net.unixdomain.tmpdir=C:/tmp`, `kotlin.incremental=false`)은 idle_tycoon 과 같다.

## 출시 체크리스트

### 1. AdMob
- [x] Android 앱 "Coloring Fun" 등록, 앱 설정에서 아동 대상 지정
- [x] 광고 단위: 배너 / 보상형
- [x] `lib/ads/ad_ids.dart` `_androidReal`, `AndroidManifest.xml` `APPLICATION_ID` 교체

### 2. 개인정보 / 정책
- [x] GitHub 저장소(공개) + Pages(`main` / `/docs`) 로 `docs/privacy-policy.html` 게시
- [x] Play Console: 타겟층(5세 이하 · 6~8세 등), 광고 있음, 데이터 보안(광고 ID 수집 안 함), 콘텐츠 등급

### 3. Google Play
- [x] 업로드 키 `android/upload-keystore.jks` + `android/key.properties` — git 제외, **따로 백업 필수**
- [x] `flutter build appbundle --release` (50.5MB, targetSdk 36)
- [x] 스토어 등록정보 en-US + ko-KR (그래픽·스크린샷 01→04), 내부 테스트 1.0.0
- [x] 비공개 테스트 Alpha (전체 국가, Internal testers + 오늘의 운세 테스터) 1.0.0 — 2026-09-30 검토 제출
- [ ] 12명 × 14일 테스트 → 프로덕션 신청
