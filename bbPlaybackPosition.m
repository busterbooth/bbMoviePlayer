//
//  bbPlaybackPosition.m
//  AthensPublic
//
//  Created by Eddie Boswell on 9/27/13.
//  Copyright (c) 2013 Athens Public Access. All rights reserved.
//

#import "bbPlaybackPosition.h"
#import "constants.h"
@implementation bbPlaybackPosition
@synthesize loading,view,slider,currentTime,remainingTime;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setClipsToBounds:YES];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [[NSBundle mainBundle] loadNibNamed:@"bbPlaybackSlider" owner:self options:nil];
        }else{
            [[NSBundle mainBundle] loadNibNamed:@"bbPlaybackSlider_iPad" owner:self options:nil];
        }
        [self.slider setThumbImage:[UIImage imageNamed:@"slide.png"] forState:UIControlStateNormal];
        [self.slider setThumbImage:[UIImage imageNamed:@"slide.png"] forState:UIControlStateSelected];
        [self.slider setThumbImage:[UIImage imageNamed:@"slide.png"] forState:UIControlStateHighlighted];
        [self.slider setThumbImage:[UIImage imageNamed:@"slide.png"] forState:UIControlStateDisabled];
        [self.slider setThumbImage:[UIImage imageNamed:@"slide.png"] forState:UIControlStateReserved];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                self.loading.center=CGPointMake(self.loading.center.x,self.loading.center.y+5);
            }else{
                self.loading.center=CGPointMake(self.loading.center.x,self.loading.center.y+5);
                self.slider.center=CGPointMake(self.slider.center.x,self.slider.center.y-5);
            }
        }
        [self addSubview:self.view];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
