//
//  ChatService.m
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-04-02.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import "ChatService.h"
#import "BLEUtility.h"
#import <stdlib.h>

NSString *chatServiceUUID = @"9a53772c-f8f7-4bac-bbb3-ffb8a77d513e";
NSString *channelCharacteristicUUID = @"d215c377-8cf3-443b-a08f-221af34fbc8c";

@implementation ChatService

- (id)init {
    [super init];

    self.connectedPeripherals = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self initPeripheral];
    
    return self;
}

// init the broadcast side of our connection
- (void)initCentral {
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
}

// init the listening side of our connection
- (void)initPeripheral {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)initService {
    NSLog(@"ChatService --- initService");
    CBUUID *serviceUID = [CBUUID UUIDWithString:chatServiceUUID];
    CBUUID *characteristicUID = [CBUUID UUIDWithString:channelCharacteristicUUID];
    
    CBMutableService *service = [[CBMutableService alloc]
                                 initWithType:serviceUID
                                 primary:YES];

    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]
                                               initWithType:characteristicUID
                                               properties: CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite
                                               value:nil
                                               permissions: CBAttributePermissionsReadable | CBAttributePermissionsWriteable];

    service.characteristics = @[characteristic];

    self.chatChannelService = service;
    self.chatChannelCharacteristic = characteristic;
    
    [self.peripheralManager addService:service];
}

- (void)peripheralDoneSettingUp {
    NSLog(@"ChatService --- peripheralDoneSettingUp");
    [self initCentral];
}

- (void)sendMessage:(NSString *)message {
    NSLog(@"ChatService --- sendMessage");

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
   
    [self.peripheralManager updateValue:data forCharacteristic:self.chatChannelCharacteristic onSubscribedCentrals:nil];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"ChatService --- DidStartAdvertising");
    [self peripheralDoneSettingUp];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"ChatService --- didAddService");

    int uid = arc4random() % 10;
    
    [self.peripheralManager startAdvertising:@{
             CBAdvertisementDataLocalNameKey: [NSString stringWithFormat:@"BLEChat %d", uid],
            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:chatServiceUUID]]
     }];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"ChatService --- PeripheralManagerDidUpdateState");
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        // when we're powered on, set up the service
        [self initService];
        return;
    }
}

#pragma mark - LeDiscoveryDelegate

- (void)discoveryDidRefresh {
    NSLog(@"ChatService --- Did refresh data from LeDiscovery");
    NSLog(@"ChatService --- Found peripherals %d", [[[LeDiscovery sharedInstance] foundPeripherals] count]);
    NSLog(@"ChatService --- ConnectedServices: %d", [[[LeDiscovery sharedInstance] connectedServices] count]);

    // since we only look for services with the BLEChat UUID anything in foundPeripherals is
    // a BLEChat node when we get here.

    for (CBPeripheral *peripheral in [[LeDiscovery sharedInstance] foundPeripherals]) {
        if (peripheral.isConnected != true) {
            NSLog(@"ChatService --- Going to connect peripheral: %@", peripheral.name);
            [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
            //[self startConnectionTimeoutMonitor:peripheral];
        }
    }
}

- (void)discoveryStatePoweredOff {
    NSLog(@"State Powered Off");
}

- (void)discoveryStatePoweredOn {
    NSLog(@"ChatService --- LeDiscovery is powered on");
    [[LeDiscovery sharedInstance] startScanningForUUIDString:chatServiceUUID];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSString *uuid = [BLEUtility CBUUIDToString:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    NSLog(@"ChatService --- DidDiscoverServices for %@", uuid);

    if ([peripheral.services count] < 1) {
        NSLog(@"Problem");
        return;
    }
    
    CBService *peripheralChatService;
    for (CBService *service in peripheral.services) {
        NSLog(@"Found a Service with UUID: %@", [BLEUtility CBUUIDToString:service.UUID]);
        if ([[BLEUtility CBUUIDToString:service.UUID] isEqualToString:chatServiceUUID]) {
            peripheralChatService = service;
            break;
        }
    }
    
    [peripheral discoverCharacteristics:nil forService:peripheralChatService];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"ChatService --- DidDiscoverCharacteristics");
    
    // subscribe to the chat characteristic

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([[BLEUtility CBUUIDToString:characteristic.UUID] isEqualToString:channelCharacteristicUUID]) {
            
            NSLog(@"Subscribing to Chat Channel: %@", [BLEUtility CBUUIDToString:characteristic.UUID]);
            [peripheral setNotifyValue:true forCharacteristic:characteristic];
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"ChatService --- DidUpdateValue");
    
    NSString *message = [BLEUtility stringFromData:characteristic.value];

    [self.delegate didReceiveMessage:message];
}

#pragma mark - LePeripheralDelegate

- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"ChatService --- didConnectPeripheral %@", peripheral.name);

    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    [self.connectedPeripherals addObject:peripheral];
}

- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Disconnected Peripheral");
}

# pragma mark - connection timeout stuff

- (void)startConnectionTimeoutMonitor:(CBPeripheral *)peripheral {
    NSLog(@"ChatService --- startConnectionTimeoutMonitor");
    
    [self cancelConnectionTimeoutMonitor:peripheral];
    [self performSelector:@selector(connectionDidTimeout:)
               withObject:peripheral
               afterDelay:4];
}

- (void)cancelConnectionTimeoutMonitor:(CBPeripheral *)peripheral {
    NSLog(@"ChatService --- cancelConnectionTimeoutMonitor");
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(connectionDidTimeout:)
                                               object:peripheral];
}

- (void)connectionDidTimeout:(CBPeripheral *)peripheral {
    NSLog(@"ChatService --- connectionDidTimeout");
    NSLog(@"ChatService --- Retrying Connection");
    
    [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
    [self startConnectionTimeoutMonitor:peripheral];
}

@end


