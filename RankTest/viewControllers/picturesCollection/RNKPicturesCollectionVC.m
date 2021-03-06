//
//  RNKPicturesCollectionVC.m
//  RankTest
//
//  Created by Rafael Bartolome on 26/11/14.
//  Copyright (c) 2014 www.rafaelbartolome.es. All rights reserved.
//

#import "RNKPicturesCollectionVC.h"
#import "RNKConstants.h"
#import "RNKDataBaseEngine.h"
#import "RNKPictureCollectionViewCell+drawer.h"
#import "RNKPhotosEngine.h"
#import "RNKPictureDetailVC.h"
#import "Photo.h"


@interface RNKPicturesCollectionVC () {
    UIRefreshControl *_refreshControl;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RNKPhotosEngine *photosEngine;

@end

@implementation RNKPicturesCollectionVC

static NSString * const reuseIdentifier = @"PictureCell";



- (void)viewDidLoad {
    DLog();

    [super viewDidLoad];

    [self.collectionView registerNib:[UINib nibWithNibName:@"RNKPictureCollectionViewCell" bundle:nil] forCellWithReuseIdentifier: reuseIdentifier];

    [self setManagedObjectContext: [[RNKDataBaseEngine sharedInstance] getManagedObjectContext]];

    [self updatePictures];

    [self createRefreshControl];

    [self updateFlowLayoutInsets];

}


- (void) createRefreshControl {

    self.collectionView.alwaysBounceVertical = YES;

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor whiteColor];

    [_refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:_refreshControl];

}

- (RNKPhotosEngine*) photosEngine {
    DLog();
    if (!_photosEngine) {
        _photosEngine = [[RNKPhotosEngine alloc] init];
    }
    return _photosEngine;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) updateFlowLayoutInsets {

    float sectionInsets = 6;

    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if (scale == 2.0f) {
            if (pixelHeight == 960.0f)
                //resolution = UIDevice_iPhone35R;
                sectionInsets = 5;
            else if (pixelHeight == 1136.0f)
                //resolution = UIDevice_iPhone4R;
                sectionInsets = 5;
            else if (pixelHeight == 1334.0f)
                //resolution = UIDevice_iPhone47R;
                sectionInsets = 22;

        } else if (scale == 1.0f && pixelHeight == 480.0f)
            //resolution = UIDevice_iPhone35;
            sectionInsets = 5;
        else if (scale == 3.0f && pixelHeight == 2208.0f)
            //resolution = UIDevice_iPhone55R;
            sectionInsets = 35;

    }

    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;

    flowLayout.sectionInset = UIEdgeInsetsMake(0, sectionInsets, 0, sectionInsets);
    
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    DLog();

    _managedObjectContext = managedObjectContext;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];

    NSString *predicateString = nil; //All pictures

    fetchRequest.predicate = [NSPredicate predicateWithFormat: predicateString];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rating"
                                                                   ascending: NO ]];

    [fetchRequest setFetchBatchSize:20];

    self.debug = NO;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: managedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
}

- (void)updatePictures {
    DLog();

    UIActivityIndicatorView *actInd;

    if (self.fetchedResultsController.fetchedObjects.count == 0 ) {
        actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        actInd.center = self.view.center;
        [actInd startAnimating];
        [self.view addSubview: actInd];
    }

    __weak __typeof(self)weakSelf = self;
    [self.photosEngine getPopularPicturesOnCompletion:^(BOOL result, NSError *error) {

        if (actInd) {
            [actInd stopAnimating];
            actInd.hidden = TRUE;
            [actInd removeFromSuperview];
        }

        [weakSelf endRefreshControl];

        if (error) {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle: @"Problems getting Pictures"
                                                  message: error.localizedDescription
                                                  preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle: @"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           DLog(@"OK action");
                                       }];
            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma - refresh control

- (void) startRefresh:(id)sender {
    [self updatePictures];
}

- (void) endRefreshControl {
    [_refreshControl endRefreshing];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    RNKPictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    /*
    if (indexPath.row == ([[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] -1)) {
        [self.photosEngine getPopularPicturesOnCompletion:^(BOOL result, NSError *error) {
            //TODO: load  more results
        }];
    }
    */

    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell drawCellWithPicture: photo];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    _selectedIndexPath = indexPath;
    
    RNKPictureDetailVC *pictureDetailVC = [[RNKPictureDetailVC alloc] initWithNibName:@"RNKPictureDetailVC" bundle:nil];

    pictureDetailVC.photo = [self.fetchedResultsController objectAtIndexPath:indexPath];;

    [self.navigationController pushViewController: pictureDetailVC animated: YES];

}

@end
