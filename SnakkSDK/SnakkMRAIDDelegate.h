//
//  SnakkMraidDelegate.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    MRAID_STATE_DEFAULT,
    MRAID_STATE_LOADING,
    MRAID_STATE_RESIZED,
    MRAID_STATE_EXPANDED,
    MRAID_STATE_HIDDEN
} SnakkMraidState;

typedef enum {
    MRAID_PLACEMENT_TYPE_INTERSTITIAL,
    MRAID_PLACEMENT_TYPE_INLINE
} SnakkMraidPlacementType;

typedef enum {
    MRAID_FORCED_ORIENTATION_PORTRAIT,
    MRAID_FORCED_ORIENTATION_LANDSCAPE,
    MRAID_FORCED_ORIENTATION_NONE
} SnakkMraidForcedOrientation;


@protocol SnakkMraidDelegate <NSObject>
@required
/*
 * allow delegate to pass configuration to adview
 */
- (NSDictionary *)mraidQueryState;

/*
 * tell delegate to close the ad
 */
- (void)mraidClose;

/*
 * notify delegate of orientation properties change
 */
- (void)mraidAllowOrientationChange:(BOOL)isOrientationChangeAllowed andForceOrientation:(SnakkMraidForcedOrientation)forcedOrientation;

/*
 * tell delegate to resize the ad container
 */
- (void)mraidResize:(CGRect)frame withUrl:(NSURL *)url isModal:(BOOL)isModal useCustomClose:(BOOL)useCustomClose;

/*
 * tell delegate to open link via internal browser
 */
- (void)mraidOpen:(NSString *)urlStr;

/*
 * tell delegate if it should render a close button over the ad or not
 */
- (void)mraidUseCustomCloseButton:(BOOL)useCustomCloseButton;

@optional

- (UIViewController *)mraidPresentingViewController;

@end
