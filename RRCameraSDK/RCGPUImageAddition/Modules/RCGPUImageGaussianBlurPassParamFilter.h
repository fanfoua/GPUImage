#import "GPUImageGaussianBlurFilter.h"

/** A Gaussian blur filter
    Interpolated optimization based on Daniel Rákos' work at http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
 */

@interface RCGPUImageGaussianBlurPassParamFilter : GPUImageGaussianBlurFilter
{
}

- (id)initRadius:(CGFloat)iRadius initSigma:(CGFloat)fSigma;

@end
