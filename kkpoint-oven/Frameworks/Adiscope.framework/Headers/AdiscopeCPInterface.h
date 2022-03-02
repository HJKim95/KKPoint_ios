//
//  AdiscopeCPInterface.h
//  Adiscope
//
//  Created by 이선학 on 2018. 8. 14..
//  Copyright © 2018년 이선학. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdiscopeError.h"

@protocol AdiscopeCPBridge4UnityDelegate <NSObject>

- (void)onInitializationSucceededCallback;
- (void)onInitializationFailedCallback:(int)code description:(const char *)description;

- (void)onOpenedCallback:(int)bannerType;
- (void)onFailedToShowCallback:(int)bannerType code:(int)code description:(const char *)description;
- (void)onLeftApplicationCallback:(int)bannerType;
- (void)onClosedCallback:(int)bannerType flag:(int)flag;

@end

@protocol AdiscopeCPDelegate
@optional

- (void)onInitializationSucceeded;
- (void)onInitializationFailed:(AdiscopeError *)error;
- (void)onOpened:(int)bannerType;
- (void)onFailedToShow:(int)bannerType error:(AdiscopeError *)error;
- (void)onLeftApplication:(int)bannerType;
- (void)onClosed:(int)bannerType flag:(int)flag;

@end

@interface AdiscopeCPInterface : NSObject

+ (instancetype)sharedInstance;

- (void)initialize;
- (void)setTrackingInfo:(NSString *)userId;
- (void)showMoreGames;
- (void)showFullScreenPopup;
- (void)showEndingPopup;

- (void)initialize:(id<AdiscopeCPBridge4UnityDelegate>)delegate;
- (void)showMoreGames:(id<AdiscopeCPBridge4UnityDelegate>)delegate;
- (void)showFullScreenPopup:(id<AdiscopeCPBridge4UnityDelegate>)delegate;
- (void)showEndingPopup:(id<AdiscopeCPBridge4UnityDelegate>)delegate;

@end
