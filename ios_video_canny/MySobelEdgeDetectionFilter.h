//
//  MySobelEdgeDetectionFilter.h
//  ios_video
//
//  Created by Lieven Govaerts on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPUImageTwoPassFilter.h"

@interface MySobelEdgeDetectionFilter : GPUImageTwoPassFilter
{
    GLint texelWidthUniform, texelHeightUniform;
    BOOL hasOverriddenImageSizeFactor;
}

// The texel width and height factors tweak the appearance of the edges. By default, they match the inverse of the filter size in pixels
@property(readwrite, nonatomic) CGFloat texelWidth; 
@property(readwrite, nonatomic) CGFloat texelHeight; 

@end
