//
//  AdiscopeMediaAdManager.h
//  AdiscopeMediaAdManager
//
//  Created by 구민재 on 2021/08/24.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Adapter.h"

@interface AdiscopeMediaAdManager : NSObject <Adapter, GADFullScreenContentDelegate>

@end
