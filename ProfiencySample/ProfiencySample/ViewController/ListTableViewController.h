//
//  ViewController.h
//  ProfiencySample
//
//  Created by Ansari on 13/11/15.
//  Copyright (c) 2015 Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *table;

//Going to store the downloaded images into a Dictionary.
@property (atomic, strong)NSMutableDictionary *ImagesCacheDictionary;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

// Store json feeds in resultant data
@property (nonatomic,retain) NSMutableArray *resultantData;

// Create session configuration for downloading images
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic, strong) NSURLSession *session;
@end

