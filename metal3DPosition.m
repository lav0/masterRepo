//
//  metal3DPosition.m
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metal3DPosition.h"
#include "transformation.h"

@implementation metal3DPosition
{
    matrix_float4x4 _rotation;
    vector_float3   _translation;
}

- (instancetype)initAtPoint:(vector_float3)point
{
    if (self = [super init])
    {
        _rotation = matrix_identity_float4x4;
        _translation = point;
    }
    
    return self;
}

- (void)rotateWithAxis:(vector_float3)axis andAngle:(float)angle
{
    _rotation = matrix_multiply(matrix_from_rotation(angle, axis.x, axis.y, axis.z),
                                _rotation);
}

- (void)moveInDirection:(vector_float3)vector
{
    _translation = _translation + vector;
}

- (matrix_float4x4)getTransformation
{
    return matrix_multiply(matrix_from_translation(_translation.x, _translation.y, _translation.z),
                           _rotation
                           );
}

@end
