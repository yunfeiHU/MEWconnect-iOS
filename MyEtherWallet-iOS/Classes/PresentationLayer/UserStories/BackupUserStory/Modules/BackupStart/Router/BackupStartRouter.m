//
//  BackupStartRouter.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 23/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurry;

#import "BackupStartRouter.h"

#import "SplashPasswordModuleInput.h"
#import "SplashPasswordModuleOutput.h"
#import "BackupWordsModuleInput.h"

static NSString *const kBackupStartToSplashPasswordSegueIdentifier = @"BackupStartToSplashPasswordSegueIdentifier";
static NSString *const kBackupStartToBackupWordsSegueIdentifier = @"BackupStartToBackupWordsSegueIdentifier";

@implementation BackupStartRouter

#pragma mark - BackupStartRouterInput

- (void) openSplashPasswordWithOutput:(id <SplashPasswordModuleOutput>)output {
  [[self.transitionHandler openModuleUsingSegue:kBackupStartToSplashPasswordSegueIdentifier] thenChainUsingBlock:^id<SplashPasswordModuleOutput>(id<SplashPasswordModuleInput> moduleInput) {
    [moduleInput configureModule];
    return output;
  }];
}

- (void) openWordsWithMnemonics:(NSArray<NSString *> *)mnemonics {
  [[self.transitionHandler openModuleUsingSegue:kBackupStartToBackupWordsSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<BackupWordsModuleInput> moduleInput) {
    [moduleInput configureModuleWithMnemonics:mnemonics];
    return nil;
  }];
}

@end