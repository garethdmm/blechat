//
//  BLEChatViewController.h
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-03-28.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatService.h"

@interface BLEChatViewController : UIViewController <ChatDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) ChatService *chatService;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) NSMutableArray *messages;

- (IBAction)didClickSend:(id)sender;

@end
