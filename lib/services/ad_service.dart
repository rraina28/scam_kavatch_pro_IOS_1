import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {

  /// ================= BANNER =================

  static BannerAd? bannerAd;
  static bool bannerReady = false;

  static const String _bannerAdUnitId =
      "ca-app-pub-8808893511254390/3203155783";

  static void loadBanner(VoidCallback onLoaded) {

    if (bannerAd != null) return;

    bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),

      listener: BannerAdListener(

        onAdLoaded: (Ad ad) {
          bannerReady = true;
          debugPrint("AdService: Banner loaded");
          onLoaded();
        },

        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          bannerReady = false;
          debugPrint(
            "AdService: Banner failed (${error.code}) ${error.message}",
          );
          ad.dispose();
          bannerAd = null;
        },

      ),
    );

    bannerAd!.load();
  }


  static Widget getBannerWidget() {

    if (!bannerReady || bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: bannerAd!.size.height.toDouble(),
      width: bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: bannerAd!),
    );
  }


  static void disposeBanner() {
    bannerAd?.dispose();
    bannerAd = null;
    bannerReady = false;
  }



  /// ================= INTERSTITIAL =================

  static InterstitialAd? interstitialAd;

  static const String _interstitialAdUnitId =
      "ca-app-pub-8808893511254390/3742570628";


  static void loadInterstitial() {

    if (interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),

      adLoadCallback: InterstitialAdLoadCallback(

        onAdLoaded: (InterstitialAd ad) {

          debugPrint("AdService: Interstitial loaded");

          interstitialAd = ad;

          interstitialAd!.setImmersiveMode(true);

          interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(

            onAdDismissedFullScreenContent: (InterstitialAd ad) {

              debugPrint("AdService: Interstitial dismissed");

              ad.dispose();
              interstitialAd = null;

              loadInterstitial();
            },

            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {

              debugPrint(
                "AdService: Interstitial failed (${error.code}) ${error.message}",
              );

              ad.dispose();
              interstitialAd = null;
            },

          );
        },

        onAdFailedToLoad: (LoadAdError error) {

          debugPrint(
            "AdService: Interstitial load failed (${error.code}) ${error.message}",
          );

          interstitialAd = null;
        },

      ),
    );
  }



  static void showInterstitial() {

    if (interstitialAd != null) {

      interstitialAd!.show();

    } else {

      debugPrint("AdService: Interstitial not ready");

    }
  }



  static void disposeInterstitial() {

    interstitialAd?.dispose();
    interstitialAd = null;
  }

}