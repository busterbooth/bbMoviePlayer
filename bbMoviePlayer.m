//
//  bbMoviePlayer.m
//  AthensPublic
//
//  Created by Eddie Boswell on 9/25/13.
//  Copyright (c) 2013 Athens Public Access. All rights reserved.
//

#import "bbMoviePlayer.h"
#import "bbPlaybackPosition.h"
#import "constants.h"
#import <Social/Social.h>
#define TOP_BAR 1010
#define BOTTOM_BAR 2020
#define MAIN_TAG 3030
#define CONTROLS_TAG 4040
#define PLAYBACK_TAG 5050
#define TITLE_LABEL 6060
#define PLAY_TAG 7070
#define SHOW 0
#define START 1
#define UPDATE 2
#define HIDE 3
@interface bbMoviePlayer ()

@end

@implementation bbMoviePlayer
@synthesize controls,main,timer,feed,feedlabel,feedname;
- (id)initWithURL:(NSString *)video withTitle:(NSString *)t
{
    self = [super init];
    if (self) {
        url=video;
        canAnimate=YES;
        showingControls=YES;
        controls=[[UIView alloc] init];
        main=[[UIView alloc] init];
        title=t;
        initial=YES;
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated{
    //re-show status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    counter=0;
    showFeed=YES;
    //hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
    if(self.view.bounds.size.width > self.view.bounds.size.height){
        mp.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    }else{
        mp.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.height, self.view.bounds.size.width);
    }
    //enable controls
    [controls setUserInteractionEnabled:YES];
    controls.frame=mp.view.frame;
    main.frame=controls.frame;
    controls.tag=CONTROLS_TAG;
    main.tag=MAIN_TAG;
    [controls addSubview:main];
    controls.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.01];
    UINavigationBar *bar=[[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,mp.view.frame.size.width,mp.view.frame.size.height/8)];
    bar.tag=TOP_BAR;
    UIToolbar *tools=[[UIToolbar alloc] initWithFrame:CGRectMake(0,controls.frame.size.height-controls.frame.size.height/8,controls.frame.size.width,controls.frame.size.height/8)];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        tools.frame=CGRectMake(0,controls.frame.size.height-50,controls.frame.size.width,50);
    }
    tools.tag=BOTTOM_BAR;
    [tools setTranslucent:YES];
    tools.barStyle=UIBarStyleBlackTranslucent;
    [bar setBarStyle:UIBarStyleBlackTranslucent];
    //this sets up the top
    [self setupNavigation:bar];
    //this sets up the bottom
    if([title hasPrefix:@"Live Stream"]){
        [self setupTools:tools isLive:YES];
    }else [self setupTools:tools isLive:NO];
    [main addSubview:bar];
    [main addSubview:tools];
    main.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    mp.controlStyle = MPMovieControlStyleNone;
    self.player = mp;
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"APA_Logo_dark_trans.png" ]];
    image.frame=CGRectMake(controls.frame.size.width/4,controls.frame.size.height/4,controls.frame.size.width/2,controls.frame.size.height/2);
    image.alpha=0.2;
    [image setContentMode:UIViewContentModeScaleAspectFit];
    feed=[[UIView alloc] initWithFrame:CGRectMake(controls.frame.size.height/16,15*controls.frame.size.height/16,controls.frame.size.width-2*controls.frame.size.height/16,controls.frame.size.height/16)];
    [feed setClipsToBounds:YES];
    [feed setBackgroundColor:[UIColor whiteColor]];
    feedname = [[UILabel alloc] initWithFrame:CGRectMake(0,0,feed.frame.size.width/4,feed.frame.size.height)];
    [feedname setTextColor:[UIColor whiteColor]];
    [feedname setBackgroundColor:[UIColor colorWithRed:64/255.0 green:153/255.0 blue:255/255.0 alpha:1]];
    [feedname setTextAlignment:NSTextAlignmentCenter];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [feedname setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
    }else{
        [feedname setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    }
    feedlabel = [[UILabel alloc] initWithFrame:CGRectMake(feedname.frame.size.width+feedname.frame.size.width/12,0,3*feed.frame.size.width/4,feed.frame.size.height)];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [feedlabel setTextAlignment:NSTextAlignmentCenter];
    }else{
        [feedlabel setTextAlignment:NSTextAlignmentLeft];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [feedlabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
    }else{
        [feedlabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
        [feedlabel setNumberOfLines:0];
        [feedlabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    [feedlabel setTextColor:[UIColor darkGrayColor]];
    [feed addSubview:feedlabel];
    [feed addSubview:feedname];
    feed.alpha=0;
    [self.player.backgroundView addSubview:image];
    [self.view addSubview:self.player.view];
    [self.view addSubview:feed];
    [self.view addSubview:controls];
    [self.player prepareToPlay];
    // add tap gesture recognizer to the player.view property
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDetectTap:)];
    tapGesture.delegate=self;
    tapGesture.numberOfTapsRequired = 1;
    [controls addGestureRecognizer:tapGesture];
    //monitor the playback state to update the pause/play button
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
/*
    //not currently implemented but it could be
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateDone:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification object:nil];
 */
    //watch for the end of the movie
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    //wait for the movie duration to become available
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDurationAvailable:)
                                                 name:MPMovieDurationAvailableNotification object:nil];
    //update the current value of the playback time.  there is no notification for this, which I think is lame.
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
    [self.player play];
}

-(NSString *)formatTime:(float)seconds{
    int s = seconds;
    int m = floor(s/60.0);
    int h = floor(m/60.0);
    if(h >= 1){
        m = m - (h * 60);
        s = s - (h * 60 * 60);
    }
    if(m >= 1){
        s = s - (m * 60);
    }
    NSString* sec = [NSString stringWithFormat:@"%d",(int)floor(s)];
    NSString* min = [NSString stringWithFormat:@"%d",(int)floor(m)];
    NSString* hour = [NSString stringWithFormat:@"%d",(int)floor(h)];
    if(m < 10){
        min = [NSString stringWithFormat:@"%@%@",@"0",min];
    }
    if(s < 10){
        sec = [NSString stringWithFormat:@"%@%@",@"0",sec];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",hour,min,sec];
}

-(void)playbackDurationAvailable:(id)sender{
    bbPlaybackPosition *pp = (bbPlaybackPosition*)[controls viewWithTag:PLAYBACK_TAG];
    if(pp!=nil) [pp.remainingTime setText:[self formatTime:self.player.duration]];
}

-(void)showFeed:(NSNumber*)p{
    int phase = [p intValue];
    switch(phase){
        case SHOW:{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{feed.alpha=1;} completion:^(BOOL finished){}];
        }
        break;
        case START:{
            [NSThread detachNewThreadSelector:@selector(getFeed) toTarget:self withObject:nil];
        }
        break;
        case UPDATE:{
            CGPoint ogcenter=feedlabel.center;
            int offset = feedlabel.frame.size.width/1.65;
            [UIView animateWithDuration:6.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{feedlabel.center=CGPointMake(feedlabel.center.x-offset,feedlabel.center.y);} completion:^(BOOL finished){feedlabel.center=ogcenter;}];
        }
        break;
        case HIDE:{
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{feed.alpha=0;} completion:^(BOOL finished){}];
        }
        break;
    }
}

-(void)getFeed{
    @autoreleasepool {
        NSURL *requestURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@",FEED_URL]];
        NSData *requestData = [[NSString stringWithFormat:@"s=ios.%@",[[UIDevice.currentDevice identifierForVendor] UUIDString]] dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:requestData];
        [request setValue:@"APA v1.00" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSError *e=nil;
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&e];
        if(data == nil){
            return;
        }
        //NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",responseText);
        NSError *jsonParsingError = nil;
        NSDictionary *userdata = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        BOOL updatethis=NO;
        for(NSString *key in userdata){
                if([key hasPrefix:@"updatenow"]){
                    if([[userdata objectForKey:key] hasPrefix:@"true"]){
                        updatethis=YES;
                    }
                }
                if([key hasPrefix:@"textline"]){
                    [feedlabel setText:[userdata objectForKey:key]];
                    [feedlabel sizeToFit];
                }
                if([key hasPrefix:@"username"]){
                    [feedname setText:[userdata objectForKey:key]];
                }
                if([key hasPrefix:@"media"]){
                }
                if([key hasPrefix:@"imageurl"]){
                }
        }
        if(updatethis){
            [self performSelectorOnMainThread:@selector(showFeed:) withObject:[NSNumber numberWithInt:SHOW] waitUntilDone:NO];
        }
    }
}

-(void)updatePlaybackProgressFromTimer:(id)sender{
    if(++counter>=17){
        [self showFeed:[NSNumber numberWithInt:HIDE]];
        counter=0;
    }else if(counter==11){
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self showFeed:[NSNumber numberWithInt:UPDATE]];
            }
    }else if((counter == 5)&&showFeed){
        [self showFeed:[NSNumber numberWithInt:START]];
    }else if((counter==3)&&initial){
        initial=NO;
        [self hideControls];
    }
    
    bbPlaybackPosition *pp = (bbPlaybackPosition*)[controls viewWithTag:PLAYBACK_TAG];
    if(pp != nil){
        [pp.currentTime setText:[self formatTime:self.player.currentPlaybackTime]];
        [pp.slider setValue:(self.player.currentPlaybackTime/self.player.duration)];
        [pp.loading setProgress:(self.player.playableDuration/self.player.duration)];
    }
}

-(void)didDetectTap:(UIGestureRecognizer*)sender{
    if(canAnimate){
        canAnimate=NO;
        if(showingControls) [self hideControls];
        else [self showControls];
    }
}

-(void)togglePlay:(UIButton*)sender{
    if([self.player playbackState]==MPMoviePlaybackStatePlaying){
        [sender setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [self.player pause];
    }else if([self.player playbackState]==MPMoviePlaybackStatePaused){
        [sender setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [self.player play];
    }
}
-(void)setupTools:(UIToolbar *)tools isLive:(BOOL)live{
    UIButton *play=[UIButton buttonWithType:UIButtonTypeCustom];
    play.frame=CGRectMake(tools.frame.size.height/8,tools.frame.size.height/4, tools.frame.size.height/2, tools.frame.size.height/2);
    [play setTitle:@"" forState:UIControlStateNormal];
    play.tag=PLAY_TAG;
    [play setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [play addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *volumeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volume.png"]];
    volumeImage.frame = CGRectMake(play.frame.size.width+tools.frame.size.height/4,tools.frame.size.height/4, tools.frame.size.height/2, tools.frame.size.height/2);
    //the mpvolumeview will only appear when running on a device
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(volumeImage.frame.size.width+volumeImage.frame.origin.x,tools.frame.size.height/4,tools.frame.size.width/4-tools.frame.size.width/12,tools.frame.size.height/4)];
    [tools addSubview:play];
    [tools addSubview:volumeImage];
    [tools addSubview: volumeView];
    if(!live){
    bbPlaybackPosition *playback = [[bbPlaybackPosition alloc] initWithFrame:CGRectMake(tools.frame.size.width/4+tools.frame.size.width/12,tools.frame.size.height/6,3*tools.frame.size.width/4,11*tools.frame.size.height/12)];
    [playback.slider addTarget:self action:@selector(skipTo:) forControlEvents:UIControlEventTouchUpInside];
    [playback.slider addTarget:self action:@selector(skipTo:) forControlEvents:UIControlEventTouchUpOutside];
    playback.tag = PLAYBACK_TAG;
    [tools addSubview:playback];
    }
}

-(void)skipTo:(UISlider*)slider{
    [self.player setCurrentPlaybackTime:slider.value*self.player.duration];
}

-(void)doneWithVideo{
    [self.player stop];
    [self dismissMoviePlayerViewControllerAnimated];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(void)viewWillDisappear:(BOOL)animated{
    if(timer){
        [timer invalidate];
        timer=nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

-(void)setupNavigation:(UINavigationBar*)bar{
    UINavigationItem *item = [[UINavigationItem alloc] init];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(bar.frame.size.width/4,0,bar.frame.size.width/2,bar.frame.size.height)];
    [label setText:title];
    [label setFont:[UIFont fontWithName:@"imagine-font" size:12.0]];
    [label setTextColor:[UIColor lightGrayColor]];
    label.tag =TITLE_LABEL;
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    item.titleView=label;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWithVideo)];
    [done setTintColor:[UIColor lightGrayColor]];
    UIBarButtonItem *showHideFeed = [[UIBarButtonItem alloc] initWithTitle:@"Feed" style:UIBarButtonItemStyleDone target:self action:@selector(toggleFeed:)];
    UIBarButtonItem *tweet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweet.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(showTwitter)];
    UIBarButtonItem *post = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"post.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showFacebook)];
    item.leftBarButtonItem = done;
    item.rightBarButtonItems = [NSArray arrayWithObjects:showHideFeed, post, tweet, nil];
    bar.items = [NSArray arrayWithObject:item];
}

-(void)toggleFeed:(UIBarButtonItem*)sender{
    if(sender.style == UIBarButtonItemStyleDone){
        sender.style=UIBarButtonItemStylePlain;
        showFeed=NO;
        [self showFeed:[NSNumber numberWithInt:HIDE]];
    }else{
        sender.style=UIBarButtonItemStyleDone;
        showFeed=YES;
    }
}

-(void)showControls{
    showingControls=YES;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{main.alpha=1;} completion:^(BOOL finished){canAnimate=YES;}];
}

-(void)hideControls{
    showingControls=NO;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{main.alpha=0;} completion:^(BOOL finished){canAnimate=YES;}];
}

-(void)playbackStateChanged:(NSNotification *)notification{
    UIButton *sender = (UIButton*)[controls viewWithTag:PLAY_TAG];
    if(sender==nil) return;
    if([self.player playbackState]==MPMoviePlaybackStatePlaying){
        [sender setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }else if([self.player playbackState]==MPMoviePlaybackStatePaused){
        [sender setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}
/*
-(void)playbackStateDone:(NSNotification *)notification{
    NSLog(@"state done");
}
*/
-(void)playbackStateFinished:(NSNotification *)notification{
    if(notification.userInfo == nil) return;
    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonUserExited) {
        [self.player stop];
        [self dismissMoviePlayerViewControllerAnimated];
        [self dismissViewControllerAnimated:YES completion:^(void){}];
        // done button clicked!
    }else{
        [self.player stop];
        UINavigationBar *bar = (UINavigationBar*)[controls viewWithTag:TOP_BAR];
        UILabel *label = (UILabel*)[bar viewWithTag:TITLE_LABEL];
        [label setText:@"Live Stream"];
        UIView *v=[controls viewWithTag:PLAYBACK_TAG];
        if(v!=nil) [v removeFromSuperview];
        self.player.contentURL=[NSURL URLWithString:@"http://athenspublic.com/streaming/live/playlist_main_v2.m3u8"];
        [self.player play];
        
    }
}

-(void)showTwitter{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        NSString *to=@"";
        if(([feedname text] != nil)&&(showFeed)){
            to=[feedname text];
        }
        SLComposeViewController *twitter =[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitter setInitialText:[NSString stringWithFormat:@"%@ %@",to,@"#athenspublic"]];
        [self presentViewController:twitter animated:YES completion:^(void){}];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter not enabled."
                                                        message:@"You must first enable twitter in your device settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)showFacebook{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        NSString *to=@"";
        if(([feedname text] != nil)&&(showFeed)){
            to=[feedname text];
        }
        SLComposeViewController *facebook =[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebook setInitialText:[NSString stringWithFormat:@"%@ %@",to,@"#athenspublic"]];
        [self presentViewController:facebook animated:YES completion:^(void){}];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook not enabled."
                                                        message:@"You must first enable facebook in your device settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(touch.view.tag == MAIN_TAG) return YES;
    else if(touch.view.tag == CONTROLS_TAG) return YES;
    else return NO;
}
@end
