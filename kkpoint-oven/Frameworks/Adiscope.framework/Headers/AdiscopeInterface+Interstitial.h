//
//  AdiscopeInterface+Interstitial.h
//  Adiscope
//
//  Created by mjgu on 2021/05/04.
//  Copyright © 2021 구민재. All rights reserved.
//

#import "Adiscope.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdiscopeInterface (Interstitial)

- (void)loadInterstitial:(NSString *)unitID;
- (void)showInterstitial;
- (BOOL)isLoadedInterstitialUnitID:(NSString *)unitID;

- (void)loadInterstitial:(NSString *)unitID callback:(id<AdiscopeBridge4UnityDelegate>)delegate;
- (BOOL)showInterstitial:(id<AdiscopeBridge4UnityDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
