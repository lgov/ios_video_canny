//
//  MyCannyNonMaxSuppressionFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyCannyNonMaxSuppressionFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"

NSString *const kMyCannyNonMaxSuppressionFragmentShaderString = SHADER_STRING
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

     gl_FragColor = vec4(0.0); // black

     // strength in r, edge_dir in a.
     float strength = texture2D(inputImageTexture, textureCoordinate).r;
     if (strength <= low_treshold) {
         return; // early return, seems to have positive effect on frame rate!
     }
     
     float edge_dir = texture2D(inputImageTexture, textureCoordinate).a;

     float new_strength;
     vec3 screen_color;

     if (edge_dir <= 45.0/180.0) { // 157,5..22,5
         float leftStrength = texture2D(inputImageTexture, leftTextureCoordinate).r;
         float rightStrength = texture2D(inputImageTexture, rightTextureCoordinate).r;
         new_strength = max(leftStrength, rightStrength);
     } else if (edge_dir <= 90.0/180.0) { // 22,5..67,5
         float topRightStrength = texture2D(inputImageTexture, topRightTextureCoordinate).r;
         float bottomLeftStrength = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
         new_strength = max(bottomLeftStrength, topRightStrength);
     } else if (edge_dir <= 135.0/180.0) { // 67,5..112,5
         float topStrength = texture2D(inputImageTexture, topTextureCoordinate).r;
         float bottomStrength = texture2D(inputImageTexture, bottomTextureCoordinate).r;
         new_strength = max(topStrength, bottomStrength);
     } else { // 112,5..157,5
         float topLeftStrength = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
         float bottomRightStrength = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;
         new_strength = max(topLeftStrength, bottomRightStrength);
     }
     
     strength = step(new_strength, strength) * strength;
//     if (strength < new_strength)
//         strength = 0.0; // black
     
     gl_FragColor = vec4(vec2(strength), strength > high_treshold, edge_dir);
 }
 );

@implementation MyCannyNonMaxSuppressionFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kMyCannyNonMaxSuppressionFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end

