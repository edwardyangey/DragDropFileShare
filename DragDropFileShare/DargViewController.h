//
//  DargViewController.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-15.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBDragDrop.h"

@interface DargViewController : UIViewController<OBOvumSource, OBDropZone,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) UITableView *myTableView;
@property (retain,nonatomic) NSArray *dataArray;
@property (strong ,nonatomic) UIImagePickerController *imagePicker;
@end
