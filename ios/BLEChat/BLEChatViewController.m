//
//  BLEChatViewController.m
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-03-28.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import "BLEChatViewController.h"

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
    
    [self.messageField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickSend:(id)sender {
    NSLog(@"ChatVC --- DidClickSend");
    NSString *message = self.messageField.text;
    [self.chatService sendMessage:message];
    [self.messages addObject:message];
    [self.tableView reloadData];
}

# pragma mark - ChatDelegate methods

- (void)didReceiveMessage:(NSString *)message {
    NSLog(@"ChatVC --- DidReceiveMessage");
    [self.messages addObject:message];
    [self.tableView reloadData];
}

- (void)serviceIsReady {
    NSLog(@"ChatVC --- ServiceIsReady");
    [self.messages addObject:@"Bluetooth is ready"];
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCell"];
    
    cell.textLabel.text = (NSString *)[self.messages objectAtIndex:indexPath.row];
    
    return cell;
}


@end
