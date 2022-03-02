//
//  AdiscopeInterface+Offerwall.h
//  Adiscope
//
//  Created by mjgu on 2021/05/04.
//  Copyright © 2021 구민재. All rights reserved.
//

#import "Adiscope.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdiscopeInterface (Offerwall)

- (BOOL)showOfferwall:(NSString *)unitID;
- (BOOL)showOfferwall:(NSString *)unitID WithFilterTabs:(NSArray<NSString *> *)offerwallFilterTabs;
- (BOOL)showOfferwall:(NSString *)unitID callback:(id<AdiscopeBridge4UnityDelegate>)delegate;
- (BOOL)showOfferwall:(NSString *)unitID WithFilterTabs:(NSArray<NSString *> *)offerwallFilterTabs callback:(id<AdiscopeBridge4UnityDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
