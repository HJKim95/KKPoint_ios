//
//  AdiscopeMediaFAN.h
//  AdiscopeMediaFAN
//  SDK Version: 1.0.7
//
//  Created by 이선학 on 2018. 10. 1..
//  Copyright © 2018년 이선학. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBAudienceNetwork/FBRewardedVideoAd.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Adapter.h"

@interface AdiscopeMediaFAN : NSObject <Adapter, FBRewardedVideoAdDelegate>

@end
