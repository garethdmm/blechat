//
//  Message.h
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-04-08.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSString *sender;
@property (strong, nonatomic) NSDate *timestamp;

@end
