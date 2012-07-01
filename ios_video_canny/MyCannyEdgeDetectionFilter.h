//
//  MyCannyEdgeDetectionFilter.h
//  ios_video
//
//  Created by Lieven Govaerts on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@class GPUImageGaussianBlurFilter;
@class MySobelEdgeDetectionFilter;
@class GPUImageSketchFilter;
@class MyCannyNonMaxSuppressionFilter;
@class CannyEdgeTrackingFilter;
@class CannyConvertEdgeToColorFilter;

@interface MyCannyEdgeDetectionFilter : GPUImageFilterGroup
{
    GPUImageGaussianBlurFilter *blurFilter;
    MySobelEdgeDetectionFilter *edgeDetectionFilter;
    MyCannyNonMaxSuppressionFilter *nonMaxSuppressionFilter;
    CannyEdgeTrackingFilter *edgeTrackingFilter;
    CannyEdgeTrackingFilter *edgeTrackingFilter2;
    CannyConvertEdgeToColorFilter *edgeToColorFilter;
}

// The image width and height factors tweak the appearance of the edges. By default, they match the filter size in pixels
@property(readwrite, nonatomic) CGFloat imageWidthFactor; 
@property(readwrite, nonatomic) CGFloat imageHeightFactor; 

// A multiplier for the blur size, ranging from 0.0 on up, with a default of 1.0
@property (readwrite, nonatomic) CGFloat blurSize;

// Any edge above this threshold will be black, and anything below white. Ranges from 0.0 to 1.0, with 0.5 as the default
@property(readwrite, nonatomic) CGFloat threshold; 

@end
