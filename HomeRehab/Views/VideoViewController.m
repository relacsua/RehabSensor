//
//  VideoViewController.m
//  HomeRehab
//
//  Created by Muhammad Muneer on 20/9/15.
//  Copyright (c) 2015 Muhammad Muneer. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()
@property (nonatomic, strong) MPMoviePlayerController * moviePlayer;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMoviePlayer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initMoviePlayer {
    
    // Measurements for centering video.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat videoHeight = 720/2;
    CGFloat videoWidth = 1080/2;
    
    // Instantiating video and adding it to the screen
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mp4"];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer.view setFrame:CGRectMake((screenWidth - videoWidth)/2, (screenHeight - videoHeight)/2, videoWidth, videoHeight)];
    [self.moviePlayer setShouldAutoplay:NO];
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.allowsAirPlay = YES;
    [self.moviePlayer prepareToPlay];
}

//- (IBAction)playMovie:(id)sender {
//    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mp4"];
//    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
//    [self.moviePlayer.view setFrame:CGRectMake(100, 200, 500, 400)];
//    [self.view addSubview:self.moviePlayer.view];
//    self.moviePlayer.fullscreen = YES;
//    self.moviePlayer.allowsAirPlay = YES;
//    
//    [self.moviePlayer play];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
