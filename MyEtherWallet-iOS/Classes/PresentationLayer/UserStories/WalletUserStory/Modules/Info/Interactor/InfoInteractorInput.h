//
//  InfoInteractorInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc.. All rights reserved.
//

@import Foundation;

@class AccountPlainObject;

@protocol InfoInteractorInput <NSObject>
- (void) configurateWithAccount:(AccountPlainObject *)account;
- (void) selectMainnetNetwork;
- (void) selectRopstenNetwork;
- (void) resetWallet;
@end
