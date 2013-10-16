//
//  DargViewController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-15.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "DargViewController.h"
#import "OBDragDropManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendView.h"
#import "Cell1.h"
#import "FileView.h"
#import "FileUpload.h"
@interface DargViewController ()
{
    FileView *fileImageview;
     OBDragDropManager *dragDropManager;
}
@end

@implementation DargViewController
@synthesize myTableView;
@synthesize dataArray;
@synthesize isOpen,selectIndex;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{
//     [aScrollView setContentOffset: CGPointMake(aScrollView.contentOffset.x, 0)];
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    dragDropManager = [OBDragDropManager sharedManager];
    CGRect viewFrame = self.view.bounds;
    CGRect frame = CGRectMake(0, 0,viewFrame.size.width,214);
    UIScrollView *friendScrollView = [[UIScrollView alloc] initWithFrame:frame];
//    //    friendScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    friendScrollView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:friendScrollView];
    
    [friendScrollView setDelegate:self];
    friendScrollView.dropZoneHandler = self;
    FriendView *imageview ;
    for (int i = 0; i<13; i++) {
        imageview = [[FriendView alloc]initWithFrame:CGRectMake((140*i),10, 130, 130)];
        imageview.image = [UIImage imageNamed:@"headImage.jpg"];
        [imageview setFriendId:[NSString stringWithFormat:@"%d", (140*i)]];
        [imageview setX:(140 * i)];
        [imageview setY:10];
        [friendScrollView addSubview:imageview];
    }
    friendScrollView.contentSize =CGSizeMake(140*13,0);
    friendScrollView.dropZoneHandler = self;
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 214, viewFrame.size.width, viewFrame.size.height -214)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.userInteractionEnabled = YES;
    [self.view addSubview:myTableView];
    
//    myTableView.sectionFooterHeight = 0;
//    myTableView.sectionHeaderHeight = 0;
    self.isOpen = NO;

    dataArray = [[NSArray alloc]initWithObjects:@"Local Files",@"Drop box",@"iCloud", nil];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return [dataArray count]+1;
        }
    }
    return 1;
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];

    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
        static NSString *CellIdentifier = @"CellName";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            fileImageview = [[FileView alloc]initWithFrame:CGRectMake(10, 10 , 60, 60)];
            fileImageview.image = [UIImage imageNamed:@"headImage.jpg"];
            fileImageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addPhoto)];
            [fileImageview addGestureRecognizer:singleTap];
            [fileImageview addGestureRecognizer:recognizer];
            [cell addSubview:fileImageview];
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell1";
        Cell1 *cell = (Cell1*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        }
        NSString *name = [dataArray objectAtIndex:indexPath.section];
        cell.titleLabel.text = name;
        [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
            
        }else
        {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
                
            }else
            {
                
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    Cell1 *cell = (Cell1 *)[self.myTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [self.myTableView beginUpdates];
    
    int section = self.selectIndex.section;
    int contentCount = [dataArray count];
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	if (firstDoInsert)
    {   [self.myTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [self.myTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	[self.myTableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.myTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen)
        [self.myTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}
#pragma mark - Tool Methods
- (void)addPhoto
{NSLog(@"jhb,b");
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = NO;
	[self presentViewController:imagePickerController animated:YES completion:NULL];
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    fileImageview.image = image;
    NSLog(@"image %@",image);
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - OBOvumSource

-(OBOvum *) createOvumFromView:(UIView*)sourceView
{
    OBOvum *ovum = [[OBOvum alloc] init];
    FileView *fileImageView = (FileView *)sourceView;
    NSLog(@"%@", [fileImageView filePath]);
    FileUpload *fUpload = [[FileUpload alloc] init];
    [fUpload setFilePath:[fileImageView filePath]];
    ovum.dataObject = fUpload;
    return ovum;
}


-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)window
{
    CGRect frame = [sourceView convertRect:sourceView.bounds toView:sourceView.window];
    frame = [window convertRect:frame fromWindow:sourceView.window];
    
    UIView *dragView = [[UIView alloc] initWithFrame:frame];
    dragView.backgroundColor = sourceView.backgroundColor;
    dragView.layer.cornerRadius = 5.0;
    dragView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    dragView.layer.borderWidth = 1.0;
    dragView.layer.masksToBounds = YES;
    return dragView;
}


-(void) dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location
{
    dragView.transform = CGAffineTransformIdentity;
    dragView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        dragView.center = location;
        dragView.transform = CGAffineTransformMakeScale(0.80, 0.80);
        dragView.alpha = 1.0;
        dragView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"headImage.jpg"]];
    }];
}

#pragma mark - OBDropZone

static NSInteger kLabelTag = 2323;

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    NSLog(@"Ovum<0x%x> %@ Entered", (int)ovum, ovum.dataObject);
    
    CGFloat red = 0.33 + 0.66 * location.y / self.view.frame.size.height;
    view.layer.borderColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 5.0;
    
    CGRect labelFrame = CGRectMake(ovum.dragView.bounds.origin.x, ovum.dragView.bounds.origin.y, ovum.dragView.bounds.size.width, ovum.dragView.bounds.size.height / 2);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = @"Ovum entered";
    label.tag = kLabelTag;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.font = [UIFont boldSystemFontOfSize:24.0];
    label.textColor = [UIColor whiteColor];
    [ovum.dragView addSubview:label];
    
    return OBDropActionMove;
}

-(void) ovumExited:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location{
    
    FileUpload *fUpload = (FileUpload *)ovum.dataObject;
    NSArray *friends = [view subviews];
    FriendView *currentDroppedFriend = nil;
    for (int i=0; i < [friends count]; i++){
        if (i != ([friends count] - 2)){
            FriendView *f1 = [friends objectAtIndex:i];
            FriendView *f2 = [friends objectAtIndex:(i+1)];
            if ([f2 isKindOfClass:[FriendView class]]){
                if (location.x  > f1.x && location.x < f2.x){
                    int diff1 = location.x - f1.x;
                    int diff2 = f2.x - location.x;
                    if (diff1 < diff2){
                        currentDroppedFriend = f1;
                    }else{
                        currentDroppedFriend = f2;
                    }
                }
            }else{
                int upperX = f1.x + 100;
                if (location.x < upperX){
                    currentDroppedFriend = f1;
                }
            }
        }
        
        if(currentDroppedFriend)
            break;
    }
    
    NSLog(@"%@", [fUpload filePath]);
}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location{
    NSLog(@"");
}


-(void) handleDropAnimationForOvum:(OBOvum*)ovum withDragView:(UIView*)dragView dragDropManager:(OBDragDropManager*)dragDropManager
{

}

-(OBDropAction) ovumMoved:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    //  NSLog(@"Ovum<0x%x> %@ Moved", (int)ovum, ovum.dataObject);
    
    CGFloat hiphopopotamus = 0.33 + 0.66 * location.y / self.view.frame.size.height;
    
    
    //  UIView *itemView = [self.view viewWithTag:[ovum.dataObject integerValue]];
    
    view.layer.borderColor = [UIColor colorWithRed:hiphopopotamus green:0.0 blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 5.0;
    
    UILabel *label = (UILabel*) [ovum.dragView viewWithTag:kLabelTag];
    label.text = @"Cannot Drop Here";
    
    return OBDropActionNone;
    
    
    
    view.layer.borderColor = [UIColor colorWithRed:0.0 green:hiphopopotamus blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 5.0;
    
    //UILabel *label = (UILabel*) [ovum.dragView viewWithTag:kLabelTag];
    // label.text = [NSString stringWithFormat:@"Ovum at %@", NSStringFromCGPoint(location)];
    
    return OBDropActionMove;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
