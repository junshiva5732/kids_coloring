#!/usr/bin/env bash
# 스토어 스크린샷 원본 캡처 (720x1280 에뮬레이터). 사용: bash tool/capture_screens.sh <ko|en|ja|zh> [serial]
set +e
L=$1; SERIAL=${2:-emulator-5554}
ADB="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe -s $SERIAL"
OUT=store/raw/$L; mkdir -p "$OUT"
PKG=com.jun5731.kids_coloring
S(){ python -c "print(int(24+$1*0.672), int(266+$2*0.672))"; }   # 그림 좌표(1000) → 화면
T(){ $ADB shell input tap $1 $2; sleep ${3:-0.4}; }
flutter build apk --debug --target-platform android-x64 --dart-define=LOCALE=$L --dart-define=DEMO=true 2>&1 | grep Built
$ADB uninstall $PKG >/dev/null 2>&1; $ADB install build/app/outputs/flutter-apk/app-debug.apk | tail -1
$ADB shell am start -n $PKG/.MainActivity >/dev/null; sleep 16
$ADB exec-out screencap -p > $OUT/s_gallery.png
T 533 790 4                                  # 꽃 열기
T 130 1175; T $(S 350 380)                   # 분홍으로 꽃잎 하나 더 (꽃잎 i=3)
$ADB exec-out screencap -p > $OUT/s_coloring.png
T $(S 425 250); T $(S 575 250)               # 남은 꽃잎 i=4,5
T 207 1095; T $(S 500 380)                   # 노랑으로 가운데 → 완성
sleep 0.6; $ADB exec-out screencap -p > $OUT/s_done.png
sleep 3; $ADB shell input keyevent BACK; sleep 2
$ADB shell input swipe 360 950 360 250 400; sleep 2
$ADB exec-out screencap -p > $OUT/s_gallery2.png
echo "captured $OUT"
