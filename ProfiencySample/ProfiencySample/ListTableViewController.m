//
//  ViewController.m
//  ProfiencySample
//
//  Created by Balasubramaniyan M on 13/11/15.
//  Copyright (c) 2015 Ansari. All rights reserved.
//

#import "ListTableViewController.h"
#import "CustomTableViewCell.h"
#import "NSDictionary+safety.h"
#import "Constants.h"
#import "DetailsList.h"

#define IC_NOIMAGE @"ic_noimage.jpg"

@interface ListTableViewController ()
@property (nonatomic, retain) NSArray* titles;
@property (nonatomic,retain) NSMutableArray *resultantData;
@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
      
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshList:)];
    self.navigationItem.rightBarButtonItem = refresh;
    
    // Do any additional setup after loading the view, typically from a nib.
   
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setCenter:self.view.center];
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    
    
    
    //Create a new NSMutableDictionary object so we can store images once they are downloaded.
    self.ImagesCacheDictionary = [[NSMutableDictionary alloc]init];
    
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"CustomCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
   // self.tableView.backgroundColor = [UIColor clearColor];
   
    

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self fetchJsonFeed];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
     DetailsList *listData = self.resultantData[indexPath.row];
     NSString *description = listData.desc.length > 0 ? listData.desc : @"No Description";
   
    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH - 160 ,9999);
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize expectedLabelSize = [self rectForText:description // <- your text here
                               usingFont:font
                           boundedBySize:maximumLabelSize].size;
   
   if (expectedLabelSize.height > 140)
       return expectedLabelSize.height + 45;
    else
        return 145;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomCell";
    CustomTableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    DetailsList *listData = self.resultantData[indexPath.row];
    cell.title.text= listData.title.length > 0 ? listData.title : @"No Title";

    
    cell.desc.text = listData.desc.length > 0 ? listData.desc : @"No Description";
    
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
    
    NSString *key =  [NSString stringWithFormat:@"%li",(long)indexPath.row];
    
    if (self.ImagesCacheDictionary[key])
    {
        cell.photo.image = [self.ImagesCacheDictionary objectForKey:key];
        
    }else if (listData.imageHref.length > 0){
        [self downloadImage:cell withImageUrl:listData.imageHref withkeys:key];
    } else {
        [self.ImagesCacheDictionary setObject:[UIImage imageNamed:IC_NOIMAGE] forKey:key];
        [cell.photo setImage:[self.ImagesCacheDictionary objectForKey:key]];
    }
    
    
    return cell;
}

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
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];

   
}

-(CGFloat)calculateHeightWithText:(NSString *)title andFont:(NSInteger)font andLabelSize:(UILabel*)label{
    
    CGRect labelRect = [title
                        boundingRectWithSize:label.frame.size
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:font]
                                     }
                        context:nil];
    
    return labelRect.size.height;
}

-(void)fetchJsonFeed {
    
    NSURL *URL = [NSURL
                  URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse
                                    *response, NSError *error) {
                                      
                                
                                      
                                      NSString *feedString = [[NSString
                                                               alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                      
                                      NSData *jsonData = [feedString dataUsingEncoding:NSUTF8StringEncoding];
                                      NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                                      self.titles = [json objectForKey:@"rows"];
                                      self.resultantData = [[NSMutableArray alloc] init];
                                      for(NSDictionary *results in [json objectForKey:@"rows"]) {
                                          
                                          DetailsList *data = [[DetailsList alloc] init];
                                          data.title = [results safeObjectForKey:@"title"];
                                          data.desc = [results safeObjectForKey:@"description"];
                                          data.imageHref = [results safeObjectForKey:@"imageHref"];
                                          
                                          [self.resultantData addObject:data];
                                      }
                                     // NSLog(@"JSON: %@", json);
                                     // NSLog(@"Error: %@", error);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                         
                                          self.title = [json objectForKey:@"title"];
                                         
                                          
                                          [self.tableView reloadData];
                                          [self.activityIndicatorView stopAnimating];
                                         
                                      });
                                     
                                       NSLog(@"NSArray: %@", self.titles);
                                  
                                  }];
    [task resume];
}

-(void)downloadImage:(CustomTableViewCell *)cell withImageUrl:(NSString*)imageUrl withkeys:(NSString*)key {
   // NSLog(@"indexkey %@ and imageurl %@",key,imageUrl);
    NSURL *url = [NSURL URLWithString:
                  imageUrl];
    
    //First create an NSURLConfiguration
    NSURLSessionConfiguration *sessionConfiguration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //Creates a session thatt conforms to the current class as a delegate.
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfiguration
                                  delegate:self
                             delegateQueue:nil];
    
    // 2
    NSURLSessionDownloadTask *downloadPhotoTask = [session
                                                   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                       // 3
                                                       UIImage *downloadedImage = [UIImage imageWithData:
                                                                                   [NSData dataWithContentsOfURL:location]];
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           NSLog(@"image %@",key);
                                                           if(downloadedImage != nil) {
                                                           [self.ImagesCacheDictionary setObject:downloadedImage forKey:key];
                                                           [cell.photo setImage:[self.ImagesCacheDictionary objectForKey:key]];
                                                           } else {
                                                               [self.ImagesCacheDictionary setObject:[UIImage imageNamed:IC_NOIMAGE] forKey:key];
                                                               [cell.photo setImage:[self.ImagesCacheDictionary objectForKey:key]];
                                                           }
                                                           
                                                           //NSLog(@"dict %@",self.ImagesCacheDictionary);
                                                          
                                                       });
                                                      
                                                   }];
    
    	
    [downloadPhotoTask resume];

}

-(void) detectOrientation {
    [self.tableView reloadData];

}


-(void)refreshList:(id)sender {
    
     [self fetchJsonFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
