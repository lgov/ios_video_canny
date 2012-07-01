//
//  CannyEdgeTrackingFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CannyEdgeTrackingFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"


// check http://http.developer.nvidia.com/GPUGems2/gpugems2_chapter40.html
NSString *const kCannyEdgeTrackingFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 uniform sampler2D inputImageTexture;
  
 void main()
 {
     const float low_treshold = 20.0/255.0;
     const float high_treshold = 200.0/255.0;

     // strength in r, edge_dir in a.
     float strength = texture2D(inputImageTexture, textureCoordinate).r;
     float edge_dir = texture2D(inputImageTexture, textureCoordinate).a;
     
     if (strength <= low_treshold) {
         gl_FragColor = vec4(0.0);
         return; // early return, seems to have positive effect on frame rate!
     }
     if (strength >= high_treshold) {
         gl_FragColor = vec4(vec3(1.0), edge_dir);
         return;
     }
     // .g = 1.0 => strong edge, .g = 0.0 => weak edge
     float strong_lefttop = texture2D(inputImageTexture, topLeftTextureCoordinate).g;
     float strong_top = texture2D(inputImageTexture, topTextureCoordinate).g;
     float strong_bottom = texture2D(inputImageTexture, bottomTextureCoordinate).g;
     float strong_rightbottom = texture2D(inputImageTexture, bottomRightTextureCoordinate).g;
     float sum1 = strong_lefttop + strong_top + strong_bottom + strong_rightbottom;

     float strong_righttop = texture2D(inputImageTexture, topRightTextureCoordinate).g;
     float strong_left = texture2D(inputImageTexture, leftTextureCoordinate).g;
     float strong_right = texture2D(inputImageTexture, rightTextureCoordinate).g;
     float strong_leftbottom = texture2D(inputImageTexture, bottomLeftTextureCoordinate).g;
     float sum2 = strong_left + strong_leftbottom + strong_right + strong_righttop;
     
     if (edge_dir <= 45.0/180.0) { // 157,5..22,5
         strength = clamp(sum1 + strong_righttop + strong_leftbottom, 0.0, 1.0);
     } else if (edge_dir <= 90.0/180.0) { // 22,5..67,5
         strength = clamp(sum2 + strong_top + strong_bottom, 0.0, 1.0);
     } else if (edge_dir <= 135.0/180.0) { // 67,5..112,5
         strength = clamp(sum2 + strong_lefttop + strong_rightbottom, 0.0, 1.0);
     } else { // 112,5..157,5
         strength = clamp(sum1 + strong_left + strong_right, 0.0, 1.0);
     }
     
     gl_FragColor = vec4(vec2(strength), strength > high_treshold, edge_dir);
 }
 );

@implementation CannyEdgeTrackingFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kCannyEdgeTrackingFilterFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end

