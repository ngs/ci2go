//
//  CI2Go-Bridging-Header.h
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <CoreData/CoreData.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <UIColor+Mix/UIColor+Mix.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MagicalRecord/MagicalRecord.h>
#import <MagicalRecord/MagicalRecord+ShorthandMethods.h>
#import <MagicalRecord/MagicalRecordShorthandMethodAliases.h>
#import "AMR_ANSIEscapeHelper.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import <CommonCrypto/CommonCrypto.h>
#import <Pusher/Pusher.h>

@interface NSManagedObject (MRPrivate)

- (NSManagedObject *) MR_findObjectForRelationship:(NSRelationshipDescription *)relationshipInfo withData:(id)singleRelatedObjectData;

@end
