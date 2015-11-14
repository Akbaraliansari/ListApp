//
//  ViewController.h
//  ProfiencySample
//
//  Created by Ansari on 13/11/15.
//  Copyright (c) 2015 Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic,strong) UITableView *table;

//Going to store the downloaded images into a Dictionary.
@property (atomic, strong)NSMutableDictionary *ImagesCacheDictionary;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

