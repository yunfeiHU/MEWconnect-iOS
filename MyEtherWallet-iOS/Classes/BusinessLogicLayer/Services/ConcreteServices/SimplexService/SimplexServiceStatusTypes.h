//
//  SimplexServiceStatusTypes.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 13/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#ifndef SimplexServiceStatusTypes_h
#define SimplexServiceStatusTypes_h

@import Foundation;

static NSString *const kSimplexServicePaymentRequestSubmitted = @"payment_request_submitted";
static NSString *const kSimplexServicePaymentApproved         = @"payment_simplexcc_approved";
static NSString *const kSimplexServicePaymentDeclined         = @"payment_simplexcc_declined";
static NSString *const kSimplexServicePaymentPending          = @"pending_simplexcc_approval";

typedef NS_ENUM(short, SimplexServicePaymentStatusType) {
  SimplexServicePaymentStatusTypeUnknown    = 0,
  SimplexServicePaymentStatusTypeInProgress = 1,
  SimplexServicePaymentStatusTypeApproved   = 2,
  SimplexServicePaymentStatusTypeDeclined   = 3,
};

NS_INLINE SimplexServicePaymentStatusType SimplexServicePaymentStatusTypeFromString(NSString *string) {
  if ([string isEqualToString:kSimplexServicePaymentRequestSubmitted] ||
      [string isEqualToString:kSimplexServicePaymentPending]) {
    return SimplexServicePaymentStatusTypeInProgress;
  } else if ([string isEqualToString:kSimplexServicePaymentApproved]) {
    return SimplexServicePaymentStatusTypeApproved;
  } else if ([string isEqualToString:kSimplexServicePaymentDeclined]) {
    return SimplexServicePaymentStatusTypeDeclined;
  } else {
    return SimplexServicePaymentStatusTypeUnknown;
  }
}

#endif /* SimplexServiceStatusTypes_h */
