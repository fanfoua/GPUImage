#import "RCGPUImageGaussianBlurPassParamFilter.h"

@implementation RCGPUImageGaussianBlurPassParamFilter

- (id)initRadius:(CGFloat)iRadius initSigma:(CGFloat)fSigma;
{
    
    NSString *currentGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:iRadius sigma:fSigma];
    NSString *currentGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfRadius:iRadius sigma:fSigma];
    
    return [super initWithFirstStageVertexShaderFromString:currentGaussianBlurVertexShader firstStageFragmentShaderFromString:currentGaussianBlurFragmentShader secondStageVertexShaderFromString:currentGaussianBlurVertexShader secondStageFragmentShaderFromString:currentGaussianBlurFragmentShader];
    return self;
}

@end