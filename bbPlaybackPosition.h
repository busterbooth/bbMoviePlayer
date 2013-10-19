//
//  bbPlaybackPosition.h
//  AthensPublic
//
//  Created by Eddie Boswell on 9/27/13.
//  Copyright (c) 2013 Athens Public Access. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface bbPlaybackPosition : UIView
@property (nonatomic,weak) IBOutlet UIView* view;
@property (nonatomic,strong) IBOutlet UISlider* slider;
@property (nonatomic,strong) IBOutlet UIProgressView* loading;
@property (nonatomic,strong) IBOutlet UILabel* currentTime;
@property (nonatomic,strong) IBOutlet UILabel* remainingTime;
@end
