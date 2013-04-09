//
//  ChatCell.h
//  BLEChat
//
//  Created by Gareth MacLeod on 2013-04-08.
//  Copyright (c) 2013 Gareth MacLeod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end
