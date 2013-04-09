//
//  BLEChatViewController.m
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-03-28.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import "BLEChatViewController.h"
#import "ChatCell.h"
#import "Message.h"

@interface BLEChatViewController ()

@end

@implementation BLEChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    CGRect screenRect = self.view.frame;
    CGRect cellRect = self.inputCell.frame;

    cellRect.origin.y = screenRect.size.height - 216 - 44; // just above the keyboard
    self.inputCell.frame = cellRect;
    
    CGRect tableRect = self.tableView.frame;
    tableRect.origin.y = 44; // just below the navbar
    tableRect.size.height = cellRect.origin.y - 44; // between the navbar and the cell
    self.tableView.frame = tableRect;
    
    self.messages = [[NSMutableArray alloc] initWithCapacity:200];
    
    self.chatService = [[ChatService alloc] init];
    [self.chatService setDelegate:self];
   
    UINib *cellNib = [UINib nibWithNibName:@"ChatCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"ChatCell"];
    
    [self.messageField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING BRO");
    // Dispose of any resources that can be recreated.
}

- (void)scrollToNewMessage {
    NSIndexPath * path = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0] - 1) inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)didClickSend:(id)sender {
    NSLog(@"ChatVC --- DidClickSend");
    NSString *message = self.messageField.text;
    [self.chatService sendMessage:message];

    Message *msg = [[Message alloc] init];
    msg.messageText = message;
    msg.sender = @"Me";
    msg.timestamp = [NSDate date];
    
    [self.messages addObject:msg];
    [self.tableView reloadData];
    [self scrollToNewMessage];
}

# pragma mark - ChatDelegate methods

- (void)didReceiveMessage:(NSString *)message fromSender:(NSString *)sender {
    NSLog(@"ChatVC --- DidReceiveMessage");

    Message *msg = [[Message alloc] init];
    msg.messageText = message;
    msg.sender = sender;
    msg.timestamp = [NSDate date];
    
    [self.messages addObject:msg];
    [self.tableView reloadData];
    [self scrollToNewMessage];
}

- (void)serviceIsReady {
    NSLog(@"ChatVC --- ServiceIsReady");
    [self.tableView reloadData];
}

# pragma mark - UITableViewDelegate 

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ChatCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
  
    Message *msg = [self.messages objectAtIndex:indexPath.row];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"hh:mm"];
    NSLog(@"%@",[DateFormatter stringFromDate:[NSDate date]]);
    
    cell.messageLabel.text = msg.messageText;
    cell.nameLabel.text = msg.sender;
    cell.timestampLabel.text = [DateFormatter stringFromDate:msg.timestamp];
    
    return cell;
}


@end
