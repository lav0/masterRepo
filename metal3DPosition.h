//
//  metal3DPosition.h
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface metal3DPosition : NSObject

- (instancetype)initAtPoint:(vector_float3)point;

- (void)rotateWithAxis:(vector_float3)vector andAngle:(float)radian;
- (void)moveInDirection:(vector_float3)vector;

- (matrix_float4x4)getTransformation;

@end
