//
//  spacePosition3D.hpp
//  masterOfPuppets
//
//  Created by Andrey on 08.09.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#ifndef spacePosition3D_hpp
#define spacePosition3D_hpp

#include <stdio.h>
#include <simd/simd.h>

class spacePosition3D
{
public:
    
    spacePosition3D(vector_float3 point);
    
    void rotateWithAxis(vector_float3 axis, float radian);
    void moveInDirection(vector_float3 vector);
    
    matrix_float4x4 getTransformation();

private:
    
    matrix_float4x4 _rotation;
    vector_float3   _translation;
};

#endif /* spacePosition3D_hpp */
