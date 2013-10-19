//
//  example.m
//  AthensPublic
//
//  Created by Eddie Boswell on 9/23/13.
//  Copyright (c) 2013 Athens Public Access. All rights reserved.
//

#import "example.h"
#import "bbMoviePlayer.h"
@interface example ()

@end

@implementation example

@synthesize scrollview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Featured", @"Featured");
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame=CGRectMake(10,self.view.frame.origin.y+20,self.view.bounds.size.width-20,50);
    [b setTitle:@"Launch bbMoviePlayer" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(watchFeature) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:b];
    f=b.frame.origin.y+b.frame.size.height+93;
    [scrollview setContentSize:CGSizeMake(self.view.bounds.size.width,f)];
}

-(void)watchFeature{
    bbMoviePlayer *mp = [[bbMoviePlayer alloc] initWithURL:@"http://athenspublic.com/featured/variant.m3u8" withTitle:@"Feature"];
    [self presentMoviePlayerViewControllerAnimated:mp];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(b != nil){
        b.frame=CGRectMake(10,self.view.frame.origin.y+20,self.view.bounds.size.width-20,50);
    }
    f=b.frame.origin.y+b.frame.size.height+25;
    [scrollview setContentSize:CGSizeMake(self.view.bounds.size.width,f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //NSLog(@"%f",[self.view viewWithTag:10].frame.size.width);
    if(b != nil){
        b.frame=CGRectMake(10,self.view.frame.origin.y+20,self.view.bounds.size.width-20,50);
    }
    f=b.frame.origin.y+b.frame.size.height+25;
    [scrollview setContentSize:CGSizeMake(self.view.bounds.size.width,f)];
}

@end
