//
//  AdiscopeInterface+RewardedVideo.h
//  Adiscope
//
//  Created by mjgu on 2021/05/04.
//  Copyright © 2021 구민재. All rights reserved.
//

#import "Adiscope.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdiscopeInterface (RewardedVideo)

- (void)load:(NSString *)unitID;
- (BOOL)isLoaded:(NSString *)unitID;
- (BOOL)show;

- (void)load:(NSString *)unitID callback:(id<AdiscopeBridge4UnityDelegate>)delegate;
- (BOOL)show:(id<AdiscopeBridge4UnityDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
