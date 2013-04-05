//
//  ChatService.h
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-04-02.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LeDiscovery.h"

extern NSString *chatServiceUUID;// = @"9a53772c-f8f7-4bac-bbb3-ffb8a77d513e";
extern NSString *channelCharacteristicUUID;// = @"d215c377-8cf3-443b-a08f-221af34fbc8c";

@class BLEChatViewController;

@protocol ChatDelegate <NSObject>

// calls the delegate when we receieve a chat message
- (void)didReceiveMessage:(NSString *)message;

// calls the delegate when all the bluetooth stuff is ready to go
- (void)serviceIsReady;

@end

@interface ChatService : NSObject <
    LeDiscoveryDelegate,
    LePeripheralDelegate,
    CBPeripheralManagerDelegate,
    CBPeripheralDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) BLEChatViewController *delegate;

@property (strong, nonatomic) NSMutableArray *connectedPeripherals;
@property (strong, nonatomic) CBMutableService *chatChannelService;
@property (strong, nonatomic) CBMutableCharacteristic *chatChannelCharacteristic;

- (void)sendMessage:(NSString *)message;

@end
