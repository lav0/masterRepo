//
//  Camera.hpp
//  masterOfPuppets
//
//  Created by Andrey on 11.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#ifndef Camera_hpp
#define Camera_hpp

#include <stdio.h>
#include <simd/simd.h>
#include "transformation.h"

class Camera
{
public:
    
    Camera();
    Camera(vector_float3& eye, vector_float3& direction, vector_float3& up);
    
    void move(const vector_float3& shift);
    
    const matrix_float4x4& get_view_transformation();
    
private:
    
    bool recalculate_view_transformation();
    
private:
    
    vector_float3 m_position    = {0.f, 0.f, 0.f};
    vector_float3 m_direction   = {0.f, 0.f, 1.f};
    vector_float3 m_orientation = {0.f, 1.f, 0.f}; // up direction
    
    matrix_float4x4 m_view_transformation     = matrix_identity_float4x4;
    bool            m_recalculate_view_needed = true;
};

#endif /* Camera_hpp */
