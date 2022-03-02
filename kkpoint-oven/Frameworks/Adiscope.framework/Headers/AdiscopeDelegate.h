//
//  AdiscopeDelegate.h
//  Adiscope
//
//  Created by mjgu on 2021/05/04.
//  Copyright © 2021 구민재. All rights reserved.
//

#ifndef AdiscopeDelegate_h
#define AdiscopeDelegate_h

@class AdiscopeError;
@class AdiscopeRewardItem;
@class AdiscopeUnitStatus;

// MARK: - AdiscopeBridge for Unity Delegate
@protocol AdiscopeBridge4UnityDelegate <NSObject>

- (void)onInitializedCallback:(BOOL)isSuccess;

- (void)onGetUnitStatusCallback:(int)code description:(const char *)description live:(BOOL)live active:(BOOL)active;

- (void)onOfferwallAdOpenedCallback:(const char *)unitId;
- (void)onOfferwallAdClosedCallback:(const char *)unitId;
- (void)onOfferwallAdFailedToShowCallback:(const char *)unitId code:(int)code description:(const char *)description;

- (void)onRewardedVideoAdLoadedCallback:(const char *)unitId;
- (void)onRewardedVideoAdFailedToLoadCallback:(const char *)unitId code:(int)code description:(const char *)description;
- (void)onRewardedVideoAdOpenedCallback:(const char *)unitId;
- (void)onRewardedVideoAdClosedCallback:(const char *)unitId;
- (void)onRewardedCallback:(const char *)unitId type:(const char *)type amount:(unsigned long long)amount;
- (void)onRewardedVideoAdFailedToShowCallback:(const char *)unitId code:(int)code description:(const char *)description;

- (void)onInterstitialAdLoadedCallback:(const char *)unitId;
- (void)onInterstitialAdFailedToLoadCallback:(const char *)unitId code:(int)code description:(const char *)description;
- (void)onInterstitialAdOpenedCallback:(const char *)unitId;
- (void)onInterstitialAdClosedCallback:(const char *)unitId;
- (void)onInterstitialAdFailedToShowCallback:(const char *)unitId code:(int)code description:(const char *)description;
@end

// MARK: - AdiscopeDelegate
@protocol AdiscopeDelegate
@optional

- (void)onInitialized:(BOOL)isSuccess;
- (void)onResponsedUnitStatus:(AdiscopeUnitStatus *)status;

- (void)onOfferwallAdOpened:(NSString *)unitID;
- (void)onOfferwallAdClosed:(NSString *)unitID;
- (void)onOfferwallAdFailedToShow:(NSString *)unitID Error:(AdiscopeError *)error;

- (void)onRewardedVideoAdLoaded:(NSString *)unitID;
- (void)onRewardedVideoAdFailedToLoad:(NSString *)unitID Error:(AdiscopeError *)error;
- (void)onRewardedVideoAdOpened:(NSString *)unitID;
- (void)onRewardedVideoAdClosed:(NSString *)unitID;
- (void)onRewarded:(NSString *)unitID Item:(AdiscopeRewardItem *)item;
- (void)onRewardedVideoAdFailedToShow:(NSString *)unitID Error:(AdiscopeError *)error;

- (void)onInterstitialAdLoaded:(NSString *)unitID;
- (void)onInterstitialAdFailedToLoad:(NSString *)unitID Error:(AdiscopeError *)error;
- (void)onInterstitialAdOpened:(NSString *)unitID;
- (void)onInterstitialAdClosed:(NSString *)unitID;
- (void)onInterstitialAdFailedToShow:(NSString *)unitID Error:(AdiscopeError *)error;
@end

#endif /* AdiscopeDelegate_h */
