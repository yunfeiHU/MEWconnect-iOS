//
//  TokensServiceImplementation.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 20/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import MagicalRecord;

#import "OperationScheduler.h"
#import "CompoundOperationBase.h"

#import "TokensOperationFactory.h"

#import "TokensServiceImplementation.h"

#import "TokensBody.h"

#import "AccountModelObject.h"
#import "AccountPlainObject.h"
#import "TokenModelObject.h"
#import "FiatPriceModelObject.h"
#import "NetworkPlainObject.h"

#define DEBUG_TOKENS 1
#if !DEBUG
  #undef DEBUG_TOKENS
  #define DEBUG_TOKENS 0
#endif

#if DEBUG_TOKENS
static NSString *const kMEWDonateAddress = @"0xDECAF9CD2367cdbb726E904cD6397eDFcAe6068D";
#endif

static NSString *const TokensABI = @"[{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"name\",\"type\":\"bool\"},{\"name\":\"website\",\"type\":\"bool\"},{\"name\":\"email\",\"type\":\"bool\"},{\"name\":\"count\",\"type\":\"uint256\"}],\"name\":\"getAllBalance\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]";
static NSString *const MainnetTokensContractAddress = @"0xBE1ecF8e340F13071761e0EeF054d9A511e1Cb56";
static NSString *const RopstenTokensContractAddress = @"0xa23707C6f68B9e5630B2310db39F1Dfa119D46A4";

@implementation TokensServiceImplementation

- (void) updateTokenBalancesForAccount:(AccountPlainObject *)account withCompletion:(TokensServiceCompletion)completion {
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  
#if DEBUG_TOKENS
  NSString *originalPublicAddress = account.publicAddress;
  if ([account.fromNetwork network] == BlockchainNetworkTypeMainnet) {
    account.publicAddress = kMEWDonateAddress;
  }
#endif
  
  NSString *contractAddress = nil;
  if ([account.fromNetwork network] == BlockchainNetworkTypeMainnet) {
    contractAddress = MainnetTokensContractAddress;
  } else {
    contractAddress = RopstenTokensContractAddress;
  }
  
  TokensBody *body = [self obtainTokensBodyWithAccount:account
                                     contractAddresses:@[contractAddress]];
#if DEBUG_TOKENS
  account.publicAddress = originalPublicAddress;
#endif
  [rootSavingContext performBlock:^{
    CompoundOperationBase *compoundOperation = [self.tokensOperationFactory contractBalancesWithBody:body];
    [compoundOperation setResultBlock:^(NSArray <TokenModelObject *> *data, NSError *error) {
      if (!error) {
        AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(publicAddress)) withValue:account.publicAddress inContext:rootSavingContext];
        if ([data isKindOfClass:[NSArray class]]) {
          if ([accountModelObject.tokens count] == 0) {
            [accountModelObject addTokens:[NSSet setWithArray:data]];
          } else {
            NSMutableArray *tokensToAdd = [[NSMutableArray alloc] initWithArray:data];
            NSMutableArray *tokensToDelete = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSArray <TokenModelObject *> *tokens = [accountModelObject.tokens allObjects];
            for (TokenModelObject *token in tokens) {
              NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", token.name];
              TokenModelObject *refreshingToken = [[data filteredArrayUsingPredicate:predicate] firstObject];
              if (refreshingToken) {
                [tokensToAdd removeObject:refreshingToken];
                [token MR_importValuesForKeysWithObject:refreshingToken];
                [tokensToAdd addObject:token];
                [tokensToDelete addObject:refreshingToken];
              } else {
                [tokensToDelete addObject:token];
              }
            }
            if ([tokensToDelete count] > 0) {
              [rootSavingContext MR_deleteObjects:tokensToDelete];
            }
            if ([tokensToAdd count] > 0) {
              [accountModelObject addTokens:[NSSet setWithArray:tokensToAdd]];
            }
          }
          [rootSavingContext MR_saveToPersistentStoreAndWait];
        }
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
          completion(error);
        }
      });
    }];
    [self.operationScheduler addOperation:compoundOperation];
  }];
}

- (NSUInteger) obtainNumberOfTokensForAccount:(AccountPlainObject *)account {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromAccount.publicAddress == %@", account.publicAddress];
  return [TokenModelObject MR_countOfEntitiesWithPredicate:predicate inContext:context];
}

- (NSDecimalNumber *) obtainTokensTotalPriceForAccount:(AccountPlainObject *)account {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromAccount.publicAddress == %@ && SELF.price != nil", account.publicAddress];
  NSArray <TokenModelObject *> *tokens = [TokenModelObject MR_findAllWithPredicate:predicate inContext:context];
  NSDecimalNumber *totalPrice = [NSDecimalNumber zero];
  for (TokenModelObject *tokenModelObject in tokens) {
    NSDecimalNumber *decimals = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:[tokenModelObject.decimals shortValue] isNegative:NO];
    NSDecimalNumber *tokenBalance = [tokenModelObject.balance decimalNumberByDividingBy:decimals];
    NSDecimalNumber *price = [tokenBalance decimalNumberByMultiplyingBy:tokenModelObject.price.usdPrice];
    totalPrice = [totalPrice decimalNumberByAdding:price];
  }
  return totalPrice;
}

#pragma mark - Private

- (TokensBody *) obtainTokensBodyWithAccount:(AccountPlainObject *)account contractAddresses:(NSArray <NSString *>*)contractAddresses {
  TokensBody *body = [[TokensBody alloc] init];
  body.address = account.publicAddress;
  body.contractAddresses = contractAddresses;
  body.abi = TokensABI;
  body.method = @"getAllBalance";
  body.nameRequired = YES;
  return body;
}

@end
