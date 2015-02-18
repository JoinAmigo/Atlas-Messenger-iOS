//
//  ATLLayerContentFactory.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

extern NSString *const ATLTestMessageText;

@interface LSLayerContentFactory : NSObject

+ (instancetype)layerContentFactoryWithLayerClient:(LYRClient *)layerClient;

- (LYRConversation *)newConversationsWithParticipants:(NSSet *)participants;

@end
