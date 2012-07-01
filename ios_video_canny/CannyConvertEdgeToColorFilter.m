//
//  CannyEdgeTrackingFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CannyConvertEdgeToColorFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"


NSString *const kCannyConvertEdgeToColorFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
  
 void main()
 {
     const float low_treshold = 20.0/255.0;

     gl_FragColor = vec4(vec3(0.0), 1.0); // black

     // strength in r, edge_dir in a.
     float strength = texture2D(inputImageTexture, textureCoordinate).r;
     if (strength <= low_treshold) {
         return; // early return, seems to have positive effect on frame rate!
     }

     float edge_dir = texture2D(inputImageTexture, textureCoordinate).a;

     vec3 screen_color;

     if (edge_dir <= 45.0/180.0) { // 157,5..22,5
         screen_color = vec3(1.0, 1.0, 0.0); // yellow         
     } else if (edge_dir <= 90.0/180.0) { // 22,5..67,5
         screen_color = vec3(0.0, 1.0, 0.0); // green
     } else if (edge_dir <= 135.0/180.0) { // 67,5..112,5
         screen_color = vec3(0.0, 0.0, 1.0); // blue
     } else { // 112,5..157,5
         screen_color = vec3(1.0, 0.0, 0.0); // red
     }
     
     gl_FragColor = vec4(vec3(screen_color), 1.0);
 }
 );

@implementation CannyConvertEdgeToColorFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kCannyConvertEdgeToColorFilterFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end

