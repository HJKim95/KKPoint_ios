//
//  AdiscopeInterface.h
//  Adiscope
//
//  Created by 이선학 on 2018. 4. 16..
//  Copyright © 2018년 이선학. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdiscopeDelegate.h"

#import "AdiscopeError.h"

#import "AdiscopeUnitStatus.h"
#import "AdiscopeRewardItem.h"

// MARK: - AdiscopeInterface
@interface AdiscopeInterface : NSObject

/// Offerwall, RewardedVideo, Insterstitial를 사용하기 위해서 Singleton Instance에 접근할 수 있습니다. RewardedVideo나 Interstitial 광고를
/// 사용하기 위해서는 반드시 AdiscopeMedia 팩을 설치해야만 합니다.
+ (instancetype)sharedInstance;

/// Offerwall, RewardedVideo, Insterstitial를 사용하기위해 초기화를 진행합니다. MediaID와 해당하는 Secret Key가 필요합니다. 필요한 정보가
/// 존재하지 않는다면 Adiscope에 문의해 주시기 바랍니다.
///
/// @param mediaId 사용하기 위한 Media의 고유한 ID
/// @param mediaSecret MediaID와 매칭되는 SecretKey
/// @param callBackTag 보상 콜백을 복수 개로 등록해서 사용할시에 어떤 보상 콜백을 사용할지 지정할 때 사용됩니다.
/// 지정하지 않을시에는 기본 보상콜백이 사용됩니다.
- (void)initialize:(NSString *)mediaId mediaSecret:(NSString *)mediaSecret callBackTag:(NSString *)callBackTag;

- (BOOL)isInitialized;

/// Offerwall, RewardedVideo, Insterstitial에 대한 이벤트 수신 Delegate.
/// @param delegate id<AdiscopeDelegate>
- (void)setMainDelegate:(id)delegate;

/// RewardedVideo, Offerwall의 보상을 받기 위한 User의 고유한 식별자입니다.
/// @param userId 보상을 받기 위한 식별자
- (BOOL)setUserId:(NSString *)userId;

/// Unit의 Status를 가져옵니다.
/// @param unitId 가져올 Status의 UnitID, Offerwall과 RewardedVideo를 상관하지 않습니다.
- (void)getUnitStatus:(NSString *)unitId;

- (void)setUseCloudFrontProxy:(BOOL)useCloudFrontProxy;

/// Adiscope SDK의 버전정보입니다. AdiscopeSDK 의CFBundleShortVersionString에서 참조하여 가져옵니다.
- (NSString *)getSDKVersion;

/// Offerwall의 IDFA경고 팝업을 띄울지 판단하는 Flag입니다.
/// useOfferwallWarningPopup NO일 경우에 IDFA Warning팝업을 보여주지 않습니다. 기본값은 YES입니다.
@property (nonatomic) BOOL useOfferwallWarningPopup;

/// iOS의 ATT 팝업을 띄울지 판단하는 Flag입니다. 기본값은 YES이며 NO일 경우에 Offerwall, RewardedVideo에 영향이 있을 수 있습니다.
@property (nonatomic) BOOL useAppTrackingTransparencyPopup;

/// ATT Popup을 사용하고 있지 않을때 사용자 설정화면으로 강제로 이동하게 할 것인지 설정하는 Flag입니다.
@property (nonatomic) BOOL enabledForcedOpenApplicationSetting;

/// Application에 사용하고 있는 Network Adapter 버전을 가져옵니다.
@property (nonatomic, weak, readonly) NSString *networkVersions;

// MARK: - Only Use for Unity
- (void)initialize:(NSString *)mediaId MediaSecret:(NSString *)mediaSecret CallBackTag:(NSString *)callBackTag Delegate:(id<AdiscopeBridge4UnityDelegate>)delegate;

- (void)getUnitStatus:(NSString *)unitId callback:(id<AdiscopeBridge4UnityDelegate>)delegate;

/// Offerwall의 탭 타입입니다.
extern NSString* const OFFERWALL_TYPE_CPS;
extern NSString* const OFFERWALL_TYPE_CPI;
extern NSString* const OFFERWALL_TYPE_CPA;
extern NSString* const OFFERWALL_TYPE_CPE;

@end
