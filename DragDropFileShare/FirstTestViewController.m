//
//  FirstTestViewController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-13.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "FirstTestViewController.h"
#import "dragdropshareAppDelegate.h"
#import <arcstreamsdk/STreamHttpRequest.h>

@interface FirstTestViewController () <FBLoginViewDelegate>

@end

@implementation FirstTestViewController

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
	// Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] init];
    
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
#ifdef __IPHONE_7_0
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        loginview.frame = CGRectOffset(loginview.frame, 5, 25);
    }
#endif
#endif
#endif
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];

}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    NSString *myUserName = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    NSLog(@"myUserName: %@",myUserName);
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    NSString *userId = user.id;
    NSLog(@"userId: %@", userId);
    
    FBRequest *friendsRequest = [FBRequest requestWithGraphPath:@"me/friends"
                                                     parameters:[NSDictionary dictionaryWithObject:@"picture.type(large),id,email,name,username"
                                                                                            forKey:@"fields"] HTTPMethod:@"GET"];
    
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            FBGraphObject *pic = [friend objectForKey:@"picture"];
            FBGraphObject *str = [pic objectForKey:@"data"];
            NSString *pUrl = [str objectForKey:@"url"];
            STreamHttpRequest *request = [[STreamHttpRequest alloc] init];
            NSData *data = [request sendRequest:@"GET" bodyData:nil withUrl:pUrl];
            
            NSLog(@"I have a friend named %@ with id %@     witUrl: %@", friend.name, friend.id, pUrl);
        }
    }];
    
    
    sleep (10);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
