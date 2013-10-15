//
//  MainController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-15.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "MainController.h"
#import "OBDragDropManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FileView.h"
#import "FileUpload.h"
#import "FriendView.h"

@interface MainController ()

@end

@implementation MainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     CGRect viewFrame = self.view.frame;
     //commit test
    
     OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
    
    CGRect frame = CGRectMake(0, 0, viewFrame.size.width,120);
     UIScrollView *rightView = [[UIScrollView alloc] initWithFrame:frame];
    rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    rightView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:rightView];
     rightView.contentSize =CGSizeMake(3500, 120);
    FriendView *imageview ;
    for (int i = 0; i<13; i++) {
        imageview = [[FriendView alloc]initWithFrame:CGRectMake((110*i), 10, 100, 100)];
        imageview.image = [UIImage imageNamed:@"headImage.jpg"];
        [imageview setFriendId:[NSString stringWithFormat:@"%d", (110*i)]];
        [imageview setX:(110 * i)];
        [imageview setY:10];
        [rightView addSubview:imageview];
    }
    
    rightView.dropZoneHandler = self;
   
    UIScrollView *leftView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 140, viewFrame.size.width, 300)];
    leftView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    leftView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:leftView];
    leftView.contentSize =CGSizeMake(viewFrame.size.width, 120*15);
    for (int i = 0; i<10; i++) {
        FileView *fileImageview = [[FileView alloc]initWithFrame:CGRectMake(10, 110*i , 100, 100)];
        [fileImageview setFilePath:[NSString stringWithFormat:@"%d", i]];
        fileImageview.image = [UIImage imageNamed:@"headImage.jpg"];
        fileImageview.userInteractionEnabled = YES;
        UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
        
        [fileImageview addGestureRecognizer:recognizer];
        [leftView addSubview:fileImageview];
    }

	// Do any additional setup after loading the view.
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
        dragView.alpha = 0.75;
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
