//
//  spacePosition3D.cpp
//  masterOfPuppets
//
//  Created by Andrey on 08.09.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "spacePosition3D.hpp"
#include "transformation.h"

spacePosition3D::spacePosition3D(vector_float3 point)
: _rotation(matrix_identity_float4x4)
, _translation(point)
{
    
}

void spacePosition3D::rotateWithAxis(vector_float3 axis, float radian)
{
    _rotation = matrix_multiply(matrix_from_rotation(radian, axis.x, axis.y, axis.z),
                                _rotation);
}

void spacePosition3D::moveInDirection(vector_float3 vector)
{
    _translation = _translation + vector;
}

matrix_float4x4 spacePosition3D::getTransformation()
{
    return matrix_multiply(matrix_from_translation(_translation.x, _translation.y, _translation.z),
                           _rotation
                           );
}