//
//  mobsolViewController.m
//  ios_video
//
//  Created by Lieven Govaerts on 29/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mobsolViewController.h"
#import "MyCannyEdgeDetectionFilter.h"
#import "MySobelEdgeDetectionFilter.h"

@interface mobsolViewController ()

@end

@implementation mobsolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GPUImageOutput<GPUImageInput> *edge_filter;
    GPUImageView *filterView = (GPUImageView *)self.view;

    edge_filter = [[MyCannyEdgeDetectionFilter alloc] init];
    [edge_filter addTarget:filterView];

    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame1280x720 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    [videoCamera addTarget:edge_filter];

    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
