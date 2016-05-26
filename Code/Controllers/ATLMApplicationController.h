//
//  ATLMApplicationController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import <Foundation/Foundation.h>
#import "ATLMAuthenticationProvider.h"
#import "ATLMLayerClient.h"

@class ATLMSplitViewController;

extern NSString *const ATLMLayerApplicationID;
extern NSString *const ATLMConversationMetadataDidChangeNotification;
extern NSString *const ATLMConversationParticipantsDidChangeNotification;
extern NSString *const ATLMConversationDeletedNotification;

/**
 @abstract The `LSApplicationController` manages global resources needed by multiple view controller classes in the Atlas Messenger App.
 It also implement the `LYRClientDelegate` protocol. Only one instance should be instantiated and it should be passed to 
 controllers that require it.
 */
@interface ATLMApplicationController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)applicationControllerWithAuthenticationProvider:(id<ATLMAuthenticating>)authenticationProvider;

- (void)authenticateWithCredentials:(NSDictionary *)credentials completion:(void (^)(LYRSession *session, NSError *error))completion;

- (void)updateWithLayerClient:(nonnull LYRClient *)client;

///--------------------------------
/// @name Global Resources
///--------------------------------

/**
 @abstract The `LSAPIManager` object for the application.
 */
@property (nonnull, nonatomic, readonly) id <ATLMAuthenticating> authenticationProvider;

/**
 @abstract The `LYRClient` object for the application.
 */
@property (nullable, nonatomic) LYRClient *layerClient;

/**
 @abstract The `ATLMSplitViewController` controller which is the application's root controller.
 */
@property (nullable, weak, nonatomic) ATLMSplitViewController *splitViewController;

@end
