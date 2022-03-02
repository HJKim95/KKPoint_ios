//
//  AdiscopeMediaTapjoy.h
//  AdiscopeMediaTapjoy
//
//  Created by mjgu on 2020/12/18.
//

#import <Foundation/Foundation.h>
#import <Tapjoy/Tapjoy.h>
#import <Tapjoy/TJPlacement.h>
#import "Adapter.h"

@interface AdiscopeMediaTapjoy : NSObject <Adapter, TJPlacementDelegate>

@end
