import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// 보상형 광고를 미리 로드해 두고 필요할 때 보여주는 싱글톤.
///
/// 아동 대상 앱(Google Play 가족 정책)이므로:
/// - 모든 광고 요청에 아동 대상 태그(COPPA)와 G 등급 제한을 건다 → 맞춤 광고 없음.
/// - 전면 광고는 쓰지 않는다. 보상형 광고는 부모 확인([ParentalGate]) 뒤 사용자가 직접 고를 때만.
/// 배너는 화면마다 붙어야 하므로 [BannerAdWidget] 에서 개별 관리한다.
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  RewardedAd? _rewarded;

  Future<void> init() async {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    await MobileAds.instance.initialize();
    loadRewarded();
  }

  bool get isRewardedReady => _rewarded != null;

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded load failed: $err');
          _rewarded = null;
        },
      ),
    );
  }

  /// 보상형 광고를 보여주고, 끝까지 봤을 때만 [onReward] 를 호출한다.
  /// 광고가 준비 안 됐으면 false 를 반환하고 아무것도 하지 않는다.
  bool showRewarded({required VoidCallback onReward, VoidCallback? onClosed}) {
    final ad = _rewarded;
    if (ad == null) return false;
    _rewarded = null;
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();
        if (earned) onReward();
        onClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadRewarded();
        onClosed?.call();
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earned = true);
    return true;
  }
}
