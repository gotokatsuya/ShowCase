//
//  ViewController.m
//  CollectionPageControll
//
//  Created by KatsuyaGoto on 2014/09/14.
//  Copyright (c) 2014年 KatsuyaGoto. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>{
        AFHTTPRequestOperationManager* manager;
}
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *images;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _images = [NSMutableArray array];
    manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.dribbble.com/"]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [self requestUrls];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.pageControl.enabled = false;
    UINib *nib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];
}


- (void) requestUrls{
    
    NSString *url = @"shots/everyone?page=1";
    
    [manager GET:url
     
      parameters:nil
     
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSLog(@"response: %@", responseObject);
             
             NSArray *shots = responseObject[@"shots"];
             for (NSDictionary *dict in shots) {
                 NSString *imageUrl= dict[@"image_url"];
                 if(imageUrl != nil){
                     [_images addObject:imageUrl];
                 }
             }
             
             self.pageControl.numberOfPages = [_images count];
             [self.collectionView reloadData];
             
         }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
         }];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = nil;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *url = _images[indexPath.item];
    [cell.imageView setImageWithURLRequest:
              [NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       cell.imageView.image = image;
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Error: %@", error);
                                   }
     ];
    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}


@end
