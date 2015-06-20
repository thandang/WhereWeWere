//
//  WWHistoryViewController.m
//  WhereWeWere
//
//  Created by Dang Thanh Than on 5/25/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "WWHistoryViewController.h"
#import "EECollectionFlowLayout.h"
#import "WWCollectionViewCell.h"
#import "SDMDataManager.h"
#import "SDMQueryOperation.h"
#import "WWPhoto.h"
#import "AppDelegate.h"
#import "BFPaperButton.h"

static NSString * const reuseIdentifier = @"cellIdentifier";

@interface WWHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SDMQueryOperationDelegate> {
    NSMutableArray  *_photos;
    NSInteger   _numCol;
    __weak UIView *_viewImage;
    __weak UIImageView *_photoViewer;
    
    UIView  *_mainView;
    UILabel *_lblDescription;
    __weak BFPaperButton *_btnClose;
}

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation WWHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadView {
    [super loadView];
    [self.navigationController setNavigationBarHidden:NO];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"History";
    CGRect mainRect = [WWUtils getMainScreenBounds];
    _numCol = (NSInteger)mainRect.size.width / kImageThumbnail;
    
    _mainView = [WWUtils getMainView];
    
    if (!_viewImage) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _mainView.frame.size.width, _mainView.frame.size.height)];
        [view setBackgroundColor:[UIColor whiteColor]];
        [_mainView addSubview:view];
        _viewImage = view;
    }
    
    if (!_photoViewer) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _viewImage.frame.size.width, _viewImage.frame.size.height)];
        [img setBackgroundColor:[UIColor whiteColor]];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [_viewImage addSubview:img];
        _photoViewer = img;
    }
    [_photoViewer setBackgroundColor:[UIColor whiteColor]];
    if (!_lblDescription) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, _viewImage.frame.size.width - 20, 100.0)];
        lbl.font = kTimeFont;
        lbl.textColor = kCOLOR_BACKGROUND;
        [_viewImage addSubview:lbl];
        _lblDescription = lbl;
    }
    
    if (!_btnClose) {
        BFPaperButton *btnClose = [[BFPaperButton alloc] initFlatWithFrame:CGRectMake(_viewImage.frame.size.width - 70.0, 20.0, 60.0, 30.0)];
        [btnClose setTitle:@"Close" forState:UIControlStateNormal];
        btnClose.layer.cornerRadius = 5.0;
        btnClose.layer.borderColor = kCOLOR_BACKGROUND.CGColor;
        btnClose.layer.borderWidth = 1.0;
        [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_viewImage addSubview:btnClose];
        [btnClose addTarget:self action:@selector(hideImage) forControlEvents:UIControlEventTouchUpInside];
        _btnClose = btnClose;
    }
    
    [_viewImage bringSubviewToFront:_btnClose];
    
    [_viewImage setHidden:YES];
    
    
    [[SDMDataManager sharedInstance] setController:self];
    [[SDMDataManager sharedInstance] getPhotos];
    [self collectionView];
}

- (void) hideImage {
    if (_viewImage) {
        [UIView animateWithDuration:0.5 animations:^{
            _viewImage.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
        }completion:^(BOOL finished){
            _viewImage.transform = CGAffineTransformIdentity;
            [_viewImage setHidden:YES];
        }];
    }
}

- (void) showImage:(WWPhoto *)photo {
    _viewImage.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [_photoViewer setImage:photo.image];
    _lblDescription.text = photo.notes;
    [_lblDescription sizeToFit];
    [_viewImage setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _viewImage.transform = CGAffineTransformIdentity;
        [_mainView bringSubviewToFront:_viewImage];
    }completion:^(BOOL finished) {
        
    }];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGRect mainRect = [WWUtils getMainScreenBounds];
        EECollectionFlowLayout *layout = [[EECollectionFlowLayout alloc] init];
        UICollectionView *coll = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 20.0, mainRect.size.width, mainRect.size.height - 40) collectionViewLayout:layout];
        [coll setBackgroundColor:[UIColor clearColor]];
        [coll setContentSize:CGSizeMake(self.view.frame.size.width, mainRect.size.height + 100)];
        [self.view addSubview:coll];
        [coll setDataSource:self];
        [coll setDelegate:self];
        [coll registerClass:[WWCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        [coll setBackgroundColor:[UIColor clearColor]];
        [coll setScrollEnabled:YES];
        
        _collectionView = coll;
    }
    return _collectionView;
}

#pragma mark - Collection
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_photos) {
        return _photos.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WWCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configPhoto:_photos[indexPath.row]];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Config show view
    WWPhoto *photo = _photos[(indexPath.section * _numCol) + indexPath.row];
    [self showImage:photo];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EECollectionFlowLayout *layout = (EECollectionFlowLayout *)collectionViewLayout;
    
    return CGSizeMake(layout.itemSize.width, layout.itemSize.height);
}

#pragma mark - Query
- (void) operation:(SDMQueryOperation *)op didFinishedWithResult:(NSArray *)result {
    if (_photos) {
        [_photos removeAllObjects];
    } else {
        _photos = [[NSMutableArray alloc] init];
    }
    if (result) {
        [_photos addObjectsFromArray:result];
    }
    [self.collectionView reloadData];
}

- (void) operation:(SDMQueryOperation *)op didInsertOrUpdateSuccess:(BOOL)success {
    
}

@end
