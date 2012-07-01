//
//  MySobelEdgeDetectionFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySobelEdgeDetectionFilter.h"
#import "GPUImageGrayscaleFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"

//   Code from "Graphics Shaders: Theory and Practice" by M. Bailey and S. Cunningham 
NSString *const kMySobelEdgeDetectionFragmentShaderString = SHADER_STRING
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
     // luminance filter first, lum component is stored in .r
     float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
     float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
     float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
     float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
     float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
     float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
     float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
     float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;

     // SobelVertical
     float Gy = topLeftIntensity + 2.0 * topIntensity + topRightIntensity - bottomLeftIntensity - 2.0 * bottomIntensity - bottomRightIntensity;
     // SobelHorizontal
     float Gx = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
     
     float strength = length(vec2(Gx, Gy));
     
     float edge_dir = atan(Gy, Gx) * 180.0 / M_PI;
     edge_dir += 180.0 + 22.5;
     edge_dir = mod(edge_dir, 180.0);
     edge_dir /= 180.0;
     
     gl_FragColor = vec4(vec3(strength), edge_dir);         
 }
 );

@implementation MySobelEdgeDetectionFilter

@synthesize texelWidth = _texelWidth; 
@synthesize texelHeight = _texelHeight; 

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kMySobelEdgeDetectionFragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}


- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    // Do a luminance pass first to reduce the calculations performed at each fragment in the edge detection phase
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:kGPUImageVertexShaderString firstStageFragmentShaderFromString:kGPUImageLuminanceFragmentShaderString secondStageVertexShaderFromString:kGPUImageNearbyTexelSamplingVertexShaderString secondStageFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    hasOverriddenImageSizeFactor = NO;
    
    texelWidthUniform = [secondFilterProgram uniformIndex:@"texelWidth"];
    texelHeightUniform = [secondFilterProgram uniformIndex:@"texelHeight"];
    
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (!hasOverriddenImageSizeFactor)
    {
        _texelWidth = 1.0 / filterFrameSize.width;
        _texelHeight = 1.0 / filterFrameSize.height;
        
        [GPUImageOpenGLESContext useImageProcessingContext];
        [secondFilterProgram use];
        glUniform1f(texelWidthUniform, _texelWidth);
        glUniform1f(texelHeightUniform, _texelHeight);
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setTexelWidth:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _texelWidth = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [secondFilterProgram use];
    glUniform1f(texelWidthUniform, _texelWidth);
}

- (void)setTexelHeight:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _texelHeight = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [secondFilterProgram use];
    glUniform1f(texelHeightUniform, _texelHeight);
}

@end

