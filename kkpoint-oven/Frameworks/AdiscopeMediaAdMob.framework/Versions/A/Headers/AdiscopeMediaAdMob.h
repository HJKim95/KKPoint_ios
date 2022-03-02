//
//  AdiscopeMediaAdMob.h
//  AdiscopeMediaAdMob
//  SDK Version: 1.0.6
//
//  Created by mjgu on 2021. 5. 10.
//  Copyright © 2021년 구민재. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "Adapter.h"

@interface AdiscopeMediaAdMob : NSObject <Adapter, GADFullScreenContentDelegate>
@end
