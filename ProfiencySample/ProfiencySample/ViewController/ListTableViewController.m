//
//  ViewController.m
//  ProfiencySample
//
//  Created by Ansari on 13/11/15.
//  Copyright (c) 2015 Ansari. All rights reserved.
//

#import "ListTableViewController.h"
#import "CustomTableViewCell.h"
#import "NSDictionary+safety.h"
#import "Constants.h"
#import "DetailsList.h"

#define IC_NOIMAGE @"ic_noimage.jpg"
#define JSON_FEED_URL @"https://dl.dropboxusercontent.com/u/746330/facts.json"

@interface ListTableViewController ()
@property (nonatomic,retain) NSMutableArray *resultantData;
@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Register notification for orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    
    // Refresh button on navigation bar
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshList:)];
    self.navigationItem.rightBarButtonItem = refresh;
    
    // Loading Activity View.
   self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setCenter:self.view.center];
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    
    //Create a new NSMutableDictionary object so we can store images once they are downloaded.
    self.ImagesCacheDictionary = [[NSMutableDictionary alloc]init];
    
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"CustomCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
   
    

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Fetch json feed from the server
    [self fetchJsonFeed];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Models for json feed
     DetailsList *listData = self.resultantData[indexPath.row];
     NSString *description = listData.desc.length > 0 ? listData.desc : @"No Description";
   
    //Calculate height of the text
    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH - 160 ,9999);
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize expectedLabelSize = [self rectForText:description // <- your text here
                               usingFont:font
                           boundedBySize:maximumLabelSize].size;
    
   if (expectedLabelSize.height > 130)
       return expectedLabelSize.height + 45;
    else
        return 145;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultantData.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomCell";
    CustomTableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // get feed data based on indexpath
    DetailsList *listData = self.resultantData[indexPath.row];
    cell.title.text= listData.title.length > 0 ? listData.title : @"No Title";
    cell.desc.text = listData.desc.length > 0 ? listData.desc : @"No Description";
    
    //Calculate height of the text
    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH - 160,9999);
    UIFont *font = [UIFont systemFontOfSize:14];
    CGRect titleRect = [self rectForText:listData.desc // <- your text here
                               usingFont:font
                           boundedBySize:maximumLabelSize];
    //adjust the label the the new height.
    CGRect newFrame = cell.desc.frame;
    newFrame.size.height = titleRect.size.height;
    cell.desc.frame = newFrame;   //cell.photo.image=[UIImage imageNamed:dict[@"icon"]];
    cell.photo.backgroundColor = [UIColor whiteColor];
   
    // Assign key for each images
    NSString *key =  [NSString stringWithFormat:@"%li",(long)indexPath.row];
   
    if (self.ImagesCacheDictionary[key])
    {
    
        cell.photo.image = [self.ImagesCacheDictionary objectForKey:key];
        
    }else {
        
        if (listData.imageHref.length > 0)
            [self downloadImage:cell withImageUrl:listData.imageHref withkeys:key];
        else {
           
            [self.ImagesCacheDictionary setObject:[UIImage imageNamed:IC_NOIMAGE] forKey:key];
            [cell.photo setImage:[self.ImagesCacheDictionary objectForKey:key]];
        }
        
    }
    
    return cell;
}

//Calculate Height of Label
-(CGRect)rectForText:(NSString *)text
           usingFont:(UIFont *)font
       boundedBySize:(CGSize)maxSize
{
    NSAttributedString *attrString =
    [[NSAttributedString alloc] initWithString:text
                                    attributes:@{ NSFontAttributeName:font}];
    
    return [attrString boundingRectWithSize:maxSize
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                    context:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    // set gradient background color of the cell
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];

   
}

// Downloading Json feed
-(void)fetchJsonFeed {
    
    // Create a url for json feed
    NSURL *URL = [NSURL
                  URLWithString:JSON_FEED_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    // Creates a session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse
                                    *response, NSError *error) {
                                      
                                
                                      
                                      NSString *feedString = [[NSString
                                                               alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                      
                                      NSData *jsonData = [feedString dataUsingEncoding:NSUTF8StringEncoding];
                                      NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                                      
                                      // Initialise nsmutablearray for json feed
                                      self.resultantData = [[NSMutableArray alloc] init];
                                      
                                      // Iterating number of records in json feeds
                                      for(NSDictionary *results in [json objectForKey:@"rows"]) {
                                          
                                          DetailsList *data = [[DetailsList alloc] init];
                                          data.title = [results safeObjectForKey:@"title"];
                                          data.desc = [results safeObjectForKey:@"description"];
                                          data.imageHref = [results safeObjectForKey:@"imageHref"];
                                          
                                          // Added json feed model in an array
                                          [self.resultantData addObject:data];
                                      }
                                     // NSLog(@"JSON: %@", json);
                                     // NSLog(@"Error: %@", error);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                         
                                          self.title = [json objectForKey:@"title"];
                                          self.tableView.delegate = self;
                                          self.tableView.dataSource = self;
                                          [self.tableView reloadData];
                                          [self.activityIndicatorView stopAnimating];
                                         
                                      });
                                  
                                  }];
    [task resume];
}

//Downloading images
-(void)downloadImage:(CustomTableViewCell *)cell withImageUrl:(NSString*)imageUrl withkeys:(NSString*)key {
   
    NSURL *url = [NSURL URLWithString:
                  imageUrl];
    
    //First create an NSURLConfiguration
    NSURLSessionConfiguration *sessionConfiguration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPMaximumConnectionsPerHost:1];
    //Creates a session thatt conforms to the current class as a delegate.
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfiguration
                                  delegate:self
                             delegateQueue:nil];
    
    
    NSURLSessionDownloadTask *downloadPhotoTask = [session
                                                   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                       
                                                       UIImage *downloadedImage = [UIImage imageWithData:
                                                                                   [NSData dataWithContentsOfURL:location]];
                                                       dispatch_sync(dispatch_get_main_queue(), ^{
                                                          
                                                           if(downloadedImage != nil) {
                                                           [self.ImagesCacheDictionary setObject:downloadedImage forKey:key];
                                                          
                                                           } else {
                                                               [self.ImagesCacheDictionary setObject:[UIImage imageNamed:IC_NOIMAGE] forKey:key];
                                                           }
                                                           NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:[key integerValue] inSection:0];
                                                           NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                                                           [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                                                           
                                                          
                                                       });
                                                      
                                                   }];
    
    	
    [downloadPhotoTask resume];

}

// Orientaion change detection
-(void) detectOrientation {
    [self.tableView reloadData];

}

// Refresh List Feed
-(void)refreshList:(id)sender {
    
    [self.resultantData removeAllObjects];
    [self.tableView reloadData];
    
     [self fetchJsonFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
