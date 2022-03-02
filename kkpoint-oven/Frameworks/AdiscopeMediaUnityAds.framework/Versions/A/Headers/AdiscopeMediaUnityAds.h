//
//  AdiscopeMediaUnityAds.h
//  AdiscopeMediaUnityAds
//  SDK Version: 1.0.7
//
//  Created by mjgu on 2021. 5. 10.
//  Copyright © 2021년 구민재. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>
#import "Adapter.h"

@interface AdiscopeMediaUnityAds : NSObject <Adapter, UnityAdsDelegate, UnityAdsLoadDelegate>

@end
