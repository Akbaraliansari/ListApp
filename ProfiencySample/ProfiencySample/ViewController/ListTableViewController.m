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

#define IC_IMAGE_NOTFOUND @"ic_noimage.jpg"
#define JSON_FEED_URL @"https://dl.dropboxusercontent.com/u/746330/facts.json"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Create session for downloading images
    _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:_sessionConfig];
    
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
    
    //Register custom cell
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:[CustomTableViewCell reuseIdentifier]];
    
    //Remove separator
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
   
    

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Fetch json feed from the server
    [self fetchJsonFeed];
    
}

// TableView Delegate Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Models for json feed
     DetailsList *listData = self.resultantData[indexPath.row];
     NSString *description = listData.desc.length > 0 ? listData.desc : @"No Description";
    
    //Calculate height of the description text
    CGSize descSize = CGSizeMake(SCREEN_WIDTH - 150 ,9999);
    UIFont *descFont = [UIFont systemFontOfSize:14];
    
    //Expected height
    CGSize expectedDescSize = [self rectForText:description // <- your text here
                               usingFont:descFont
                           boundedBySize:descSize].size;
    
    
    CGFloat totalHeight = expectedDescSize.height;
   if (totalHeight > 130)
       return totalHeight + 60;
    else
        return 170;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultantData.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CustomTableViewCell reuseIdentifier]];
    
    // Get feed data based on indexpath
    DetailsList *listData = self.resultantData[indexPath.row];
    NSString *title=  listData.title.length > 0 ? listData.title : @"No Title";
    cell.title.text = title;
    
   
    NSString *description = listData.desc.length > 0 ? listData.desc : @"No Description";
    cell.desc.text = description;
    
    //Calculate height of the text
    CGSize descSize = CGSizeMake(SCREEN_WIDTH - 150,9999);
    UIFont *descFont = [UIFont systemFontOfSize:14];
    
    CGRect expectedDescRect = [self rectForText:description // <- your text here
                               usingFont:descFont
                           boundedBySize:descSize];
    //Adjust the label to the new height.
    CGRect descFrame = cell.desc.frame;
    descFrame.size.height = expectedDescRect.size.height;
    
    // Set description frame
    cell.desc.frame = descFrame;
    
   
    // Assign key for each images
    NSString *key =  [NSString stringWithFormat:@"%li",(long)indexPath.row];
    
    // Cancel when scroll the tableview
    if (cell.imageDownloadTask)
    {
        [cell.imageDownloadTask cancel];
    }
    
    [cell.activityView startAnimating];
    cell.photo.image = nil;
    
    // Check Image Exists
    if (![self.ImagesCacheDictionary valueForKey:key])
    {
        // Set Image Url
        NSURL *imageURL = [NSURL URLWithString:listData.imageHref];
        if (imageURL)
        {
           // Send request to download image
            cell.imageDownloadTask = [_session dataTaskWithURL:imageURL
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                          if (error)
                                          {
                                              //NSLog(@"ERROR: %@", error);
                                              [self.ImagesCacheDictionary setValue:[UIImage imageNamed:IC_IMAGE_NOTFOUND] forKey:key];
                                              [cell.photo setImage:[UIImage imageNamed:IC_IMAGE_NOTFOUND]];
                                               [cell.activityView stopAnimating];
                                              
                                          }
                                          else
                                          {
                                             
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              
                                              if (httpResponse.statusCode == 200)
                                              {
                                                  UIImage *image = [UIImage imageWithData:data];
                                                  
                                                [self.ImagesCacheDictionary setValue:image forKey:key];
                                                [cell.photo setImage:image];
                                                [cell.activityView stopAnimating];
                                                 
                                              }
                                              else
                                              {
                                                 /// NSLog(@"Couldn't load image at URL: %@", imageURL);
                                                //  NSLog(@"HTTP %ld", (long)httpResponse.statusCode);
                                                  [self.ImagesCacheDictionary setValue:[UIImage imageNamed:IC_IMAGE_NOTFOUND] forKey:key];
                                                  [cell.photo setImage:[UIImage imageNamed:IC_IMAGE_NOTFOUND]];
                                                   [cell.activityView stopAnimating];
                                              }
                                          }
                                               });
                                      }];
            
            [cell.imageDownloadTask resume];
        }
    }
    else {
        
        // Set loaded image in the cell
        [cell.photo setImage:[self.ImagesCacheDictionary valueForKey:key]];
        [cell.activityView stopAnimating];
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


// Orientaion change detection
-(void) detectOrientation {
    [self.tableView reloadData];

}

// Refresh List Feed
-(void)refreshList:(id)sender {
    // Refresh Json Feeds
    [self.resultantData removeAllObjects];
    [self.tableView reloadData];
    [self.activityIndicatorView startAnimating];
    [self fetchJsonFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
