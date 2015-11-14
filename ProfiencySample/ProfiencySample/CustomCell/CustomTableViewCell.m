//
//  CustomTableViewCell.m
//  
//
//  Created by Ansari on 13/11/15.
//
//

#import "CustomTableViewCell.h"
#import "Constants.h"

@implementation CustomTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.font = [UIFont boldSystemFontOfSize:18];
        self.title.textColor = [UIColor redColor];
        [self addSubview:self.title];
        
        self.desc = [[UILabel alloc] initWithFrame:CGRectZero];
        self.desc.numberOfLines = 0;
        self.desc.font = [UIFont systemFontOfSize:14];
        self.desc.lineBreakMode = NSLineBreakByWordWrapping;
        self.desc.textAlignment = NSTextAlignmentJustified;
        [self addSubview:self.desc];
        
        self.photo =[[UIImageView alloc] initWithFrame:CGRectZero];
        self.photo.image = [UIImage imageNamed:@"ic_image_bg.png"];
        [self addSubview:self.photo];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    return self;
}



-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.title sizeToFit];

    CGRect rect=self.title.frame;
    rect.origin.x= 10;
    rect.origin.y= 10;
    rect.size.width = SCREEN_WIDTH - 160;
    self.title.frame=rect;
    
    rect=self.desc.frame;
    rect.origin.x=10;
    rect.size.width = SCREEN_WIDTH - 160;
    rect.origin.y=CGRectGetHeight(self.title.frame) + 20;
    self.desc.frame=rect;
    
    rect=self.photo.frame;
    rect.origin.x= SCREEN_WIDTH - 120;
    rect.origin.y=CGRectGetHeight(self.title.frame) + 10;
    rect.size.width=100;
    rect.size.height=100;
    self.photo.frame=rect;
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)reuseIdentifier {
    
    return @"CustomCell";
}

@end
