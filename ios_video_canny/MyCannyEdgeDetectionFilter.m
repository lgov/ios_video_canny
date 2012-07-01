//
//  MyCannyEdgeDetectionFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyCannyEdgeDetectionFilter.h"
#import "MySobelEdgeDetectionFilter.h"
#import "MyCannyNonMaxSuppressionFilter.h"
#import "CannyEdgeTrackingFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageThresholdEdgeDetection.h"
#import "GPUImageSketchFilter.h"
#import "CannyConvertEdgeToColorFilter.h"

@implementation MyCannyEdgeDetectionFilter

@synthesize threshold;
@synthesize blurSize;
@synthesize imageWidthFactor;
@synthesize imageHeightFactor;

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    // First pass: apply a variable Gaussian blur
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [self addFilter:blurFilter];
    
    // Second pass: run the Sobel edge detection on this blurred image
    edgeDetectionFilter = [[MySobelEdgeDetectionFilter alloc] init];
    [self addFilter:edgeDetectionFilter];
    [blurFilter addTarget:edgeDetectionFilter];
    
    // Third pass: trim down edges to one pixel thick
    nonMaxSuppressionFilter = [[MyCannyNonMaxSuppressionFilter alloc] init];
    [self addFilter:nonMaxSuppressionFilter];
    [edgeDetectionFilter addTarget:nonMaxSuppressionFilter];

    // Fourth pass: connect weak and strong edges, multiple iterations
    edgeTrackingFilter = [[CannyEdgeTrackingFilter alloc]init];
    [self addFilter:edgeTrackingFilter];
    [nonMaxSuppressionFilter addTarget:edgeTrackingFilter];

    edgeTrackingFilter2 = [[CannyEdgeTrackingFilter alloc]init];
    [self addFilter:edgeTrackingFilter2];
    [edgeTrackingFilter addTarget:edgeTrackingFilter2];
    
    // Show edges in color red, green, yellow, blue.
    edgeToColorFilter = [[CannyConvertEdgeToColorFilter alloc]init];
    [self addFilter:edgeToColorFilter];
    [edgeTrackingFilter2 addTarget:edgeToColorFilter];

    self.initialFilters = [NSArray arrayWithObject:blurFilter];
    self.terminalFilter = edgeToColorFilter;
    
    self.blurSize = 1.5;
    self.threshold = 0.9;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setBlurSize:(CGFloat)newValue;
{
    blurFilter.blurSize = newValue;
}

- (CGFloat)blurSize;
{
    return blurFilter.blurSize;
}

- (void)setTexelWidth:(CGFloat)newValue;
{
    edgeDetectionFilter.texelWidth = newValue;
}

- (CGFloat)texelWidth;
{
    return edgeDetectionFilter.texelWidth;
}

- (void)setTexelHeight:(CGFloat)newValue;
{
    edgeDetectionFilter.texelHeight = newValue;
}

- (CGFloat)texelHeight;
{
    return edgeDetectionFilter.texelHeight;
}

- (void)setThreshold:(CGFloat)newValue;
{
}

- (CGFloat)threshold;
{
    return 0;
}

@end
