//
//  CustomTableViewCell.h
//  
//
//  Created by Ansari on 13/11/15.
//
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) NSString *key;
+(NSString *)reuseIdentifier;

@end
