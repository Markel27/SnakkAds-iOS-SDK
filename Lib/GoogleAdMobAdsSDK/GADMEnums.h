//
//  GADMEnums.h
//  Google Ads iOS SDK
//
//  Copyright 2011 Google. All rights reserved.
//

// These are the types of animation we employ for transitions between two
// mediated ads.
typedef enum {
  kGADMBannerAnimationTypeNone           = 0,
  kGADMBannerAnimationTypeFlipFromLeft   = 1,
  kGADMBannerAnimationTypeFlipFromRight  = 2,
  kGADMBannerAnimationTypeCurlUp         = 3,
  kGADMBannerAnimationTypeCurlDown       = 4,
  kGADMBannerAnimationTypeSlideFromLeft  = 5,
  kGADMBannerAnimationTypeSlideFromRight = 6,
  kGADMBannerAnimationTypeFadeIn         = 7,
  kGADMBannerAnimationTypeRandom         = 8,
} GADMBannerAnimationType;
