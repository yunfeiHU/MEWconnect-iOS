//
//  InfoInteractor.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "InfoInteractor.h"

#import "InfoInteractorOutput.h"

#import "BlockchainNetworkService.h"
#import "AccountsService.h"

@interface InfoInteractor ()
@property (nonatomic, strong) AccountPlainObject *account;
@end

@implementation InfoInteractor

#pragma mark - InfoInteractorInput

- (void) configurateWithAccount:(AccountPlainObject *)account {
  _account = account;
}

- (void) resetWallet {
  [self.accountsService deleteAccount:self.account];
}

@end
