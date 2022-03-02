//
//  RewardedVideoError.h
//  Adiscope
//
//  Created by 이선학 on 2018. 4. 30..
//  Copyright © 2018년 이선학. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AdiscopeErrorCode) {
    INTERNAL_ERROR          = 0,
    MEDIATION_ERROR         = 1,
    INITIALIZE_ERROR        = 2,
    SERVER_SETTING_ERROR    = 3,
    INVALID_REQUEST         = 4,
    NETWORK_ERROR           = 5,
    NO_FILL                 = 6,
    TIME_LIMIT              = 7,
    NOT_EXIST_IDFA          = 8,
 // GOOGLE_FAMILY_ERROR     = 9,  (Only Android)
 // INVALID_ADID            = 10, (Only Android)
    TIME_OUT                = 11,
    SHOW_CALLED_BEFORE_LOAD = 12
};

@interface AdiscopeError : NSError
+ (AdiscopeError *)errorCode:(AdiscopeErrorCode)code;
@end
