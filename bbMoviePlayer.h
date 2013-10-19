//
//  bbMoviePlayer.h
//  AthensPublic
//
//  Created by Eddie Boswell on 9/25/13.
//  Copyright (c) 2013 Athens Public Access. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface bbMoviePlayer : MPMoviePlayerViewController <UIGestureRecognizerDelegate>{
    NSString *url;
    NSString *title;
    BOOL canAnimate;
    BOOL showingControls;
    int counter;
    BOOL showFeed;
    BOOL initial;
}
@property (nonatomic,strong) MPMoviePlayerController* player;
@property (nonatomic,strong) UIView* controls;
@property (nonatomic,strong) UIView* main;
@property (nonatomic,strong) UIView* feed;
@property (nonatomic,strong) UILabel* feedlabel;
@property (nonatomic,strong) UILabel* feedname;
@property (nonatomic,weak) NSTimer* timer;
- (id)initWithURL:(NSString *)video withTitle:(NSString *)t;
@end
