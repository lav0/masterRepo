//
//  transformation.h
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#ifndef transformation_h
#define transformation_h


static matrix_float4x4 matrix_from_perspective_fov_aspectLH(const float fovY,
                                                            const float aspect,
                                                            const float nearZ,
                                                            const float farZ)
{
    float yscale = 1.0f / tanf(fovY * 0.5f); // 1 / tan == cot
    float xscale = yscale / aspect;
    float q = farZ / (farZ - nearZ);
    
    matrix_float4x4 m = {
        .columns[0] = { xscale, 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, yscale, 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, q, 1.0f },
        .columns[3] = { 0.0f, 0.0f, q * -nearZ, 0.0f }
    };
    
    return m;
}

static matrix_float4x4 matrix_look_along(const vector_float3 eye,
                                         const vector_float3 direction,
                                         const vector_float3 up)
{
    vector_float3 R2 = vector_normalize(direction);
    
    vector_float3 R0 = vector_cross(up, direction);
    R0 = vector_normalize(R0);
    
    vector_float3 R1 = vector_cross(R2, R0);
    
    vector_float3 eye_neg = - eye;
    
    float D0 = vector_dot(R0, eye_neg);
    float D1 = vector_dot(R1, eye_neg);
    float D2 = vector_dot(R2, eye_neg);
    
    matrix_float4x4 m = {
        .columns[0] = {
            R0.x, R0.y, R0.z, D0
        },
        .columns[1] = {
            R1.x, R1.y, R1.z, D1
        },
        .columns[2] = {
            R2.x, R2.y, R2.z, D2
        },
        .columns[3] = {
            0.f, 0.f, 0.f, 1.f
        }
    };
    
    return matrix_transpose(m);
}

static matrix_float4x4 matrix_look_at(const vector_float3 eye,
                                      const vector_float3 target,
                                      const vector_float3 up)
{
    vector_float3 direction = target - eye;
    
    return matrix_look_along(eye, direction, up);
}

static matrix_float4x4 matrix_from_translation(float x, float y, float z)
{
    matrix_float4x4 m = matrix_identity_float4x4;
    m.columns[3] = (vector_float4) { x, y, z, 1.0 };
    return m;
}

static matrix_float4x4 matrix_from_rotation(float radians, float x, float y, float z)
{
    vector_float3 v = vector_normalize(((vector_float3){x, y, z}));
    float cos = cosf(radians);
    float cosp = 1.0f - cos;
    float sin = sinf(radians);
    
    matrix_float4x4 m = {
        .columns[0] = {
            cos + cosp * v.x * v.x,
            cosp * v.x * v.y + v.z * sin,
            cosp * v.x * v.z - v.y * sin,
            0.0f,
        },
        
        .columns[1] = {
            cosp * v.x * v.y - v.z * sin,
            cos + cosp * v.y * v.y,
            cosp * v.y * v.z + v.x * sin,
            0.0f,
        },
        
        .columns[2] = {
            cosp * v.x * v.z + v.y * sin,
            cosp * v.y * v.z - v.x * sin,
            cos + cosp * v.z * v.z,
            0.0f,
        },
        
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f
        }
    };
    return m;
}


#endif /* transformation_h */
