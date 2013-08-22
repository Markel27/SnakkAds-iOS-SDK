/**
 * Include this file in your App Delegate if you're not using AdMob, 
 * but are getting AdMob related errors during compile time
 */


typedef struct GADAdSize {
    CGSize size;
    NSUInteger flags;
} GADAdSize;

GADAdSize const kGADAdSizeBanner;
GADAdSize const kGADAdSizeMediumRectangle;
GADAdSize const kGADAdSizeFullBanner;
GADAdSize const kGADAdSizeLeaderboard;
GADAdSize const kGADAdSizeSkyscraper;
GADAdSize const kGADAdSizeSmartBannerPortrait;
GADAdSize const kGADAdSizeSmartBannerLandscape;
GADAdSize const kGADAdSizeInvalid;


CGSize CGSizeFromGADAdSize(GADAdSize size) {
    return CGSizeZero;
}

BOOL GADAdSizeEqualToSize(GADAdSize size1, GADAdSize size2) {
    return NO;
}

NSString *NSStringFromGADAdSize(GADAdSize size) {
    return nil;
}

