//
//  ContactCell.m
//  iCloud-Api
//
//  Created by chhu02 on 2019/6/17.
//  Copyright © 2019 chase. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width, self.bounds.size.height/2.0)];
        [self addSubview:self.nameLabel];
        
        self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.bounds.size.height/2.0, self.bounds.size.width, self.bounds.size.height/2.0)];
        [self addSubview:self.phoneLabel];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
