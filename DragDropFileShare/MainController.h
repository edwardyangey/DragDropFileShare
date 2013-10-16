//
//  MainController.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-15.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBDragDrop.h"
@interface MainController : UIViewController  <OBOvumSource, OBDropZone, UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView* _tableView;
    NSInteger _currentSection;
    NSInteger _currentRow;
    
}
@property(nonatomic, retain) NSMutableArray* headViewArray;
@property(strong, nonatomic)UITableView *myTableView;

@end
