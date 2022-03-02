//
//  AdiscopeUnitStatus.h
//  Adiscope
//
//  Created by mjgu on 2021/04/30.
//  Copyright © 2021 구민재. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdiscopeError;

@interface AdiscopeUnitStatus : NSObject
@property (nonatomic, strong, nullable) AdiscopeError *error;
@property (nonatomic) BOOL live;
@property (nonatomic) BOOL active;

+ (instancetype _Nonnull)newObject:(BOOL)live Active:(BOOL)active;
+ (instancetype _Nonnull)newError:(NSUInteger)code;
@end
