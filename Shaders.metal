//
//  Shaders.metal
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright (c) 2016 Andrey. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
#include "SharedStructures.h"

using namespace metal;

// Variables in constant address space
constant float3 light_position = float3(0.0, 1.0, -1.0);
constant float4 ambient_color  = float4(0.18, 0.24, 0.8, 1.0);
constant float4 ambient_skin   = float4(238 / 255.f, 206 / 255.f, 179 / 255.f, 1.0);
constant float4 diffuse_color  = float4(0.4, 0.4, 1.0, 1.0);

typedef struct
{
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
} vertex_t;

struct VertexPosNormal
{
    float4 position;
    float4 normal;
};

struct TextureIn
{
    float2 coordinates;
};

typedef struct {
    float4 position [[position]];
    half4  color;
} ColorInOut;

typedef struct {
    float4 position [[position]];
    float4 color;
    float2 texture_coord;
} ColorAndTextureInOut ;

// Vertex shader function
vertex ColorInOut lighting_vertex( vertex_t vertex_array [[stage_in]],
                                  constant uniforms_t& uniforms [[ buffer(1) ]])
{
    ColorInOut out;
    
    float4 in_position = float4(vertex_array.position, 1.0);
    out.position = uniforms.modelview_projection_matrix * in_position;
    
    float4 eye_normal = normalize(uniforms.normal_matrix * float4(vertex_array.normal, 0.0));
    float n_dot_l = dot(eye_normal.rgb, normalize(light_position));
    n_dot_l = fmax(0.0, n_dot_l);
    
    out.color = half4(ambient_color + diffuse_color * n_dot_l);
    return out;
}

vertex ColorAndTextureInOut lighting_vertex0(device VertexPosNormal*    vertex_array[[ buffer(0) ]],
                                             constant uniforms_t& uniforms [[ buffer(1) ]],
                                             device TextureIn* textureArray[[ buffer(2) ]],
                                             unsigned int      vid         [[ vertex_id ]])
{
    ColorAndTextureInOut out;
    
    float4 in_position = vertex_array[vid].position;
    out.position = uniforms.modelview_projection_matrix * in_position;
    
    float4 eye_normal = normalize(uniforms.normal_matrix * float4(0.f, 0.f, 1.f, 0.f));
    float n_dot_l = dot(eye_normal.rgb, normalize(light_position));
    n_dot_l = fmax(0.0, n_dot_l);
    
    out.color = float4(ambient_skin + diffuse_color * n_dot_l);
    
    out.texture_coord = textureArray[vid].coordinates;
    
    return out;
}

// Fragment shader function
fragment half4 lighting_fragment(ColorInOut in [[stage_in]])
{
    return in.color;
}

fragment float4 lighting_fragment0(ColorAndTextureInOut in [[stage_in]],
                                  texture2d<float, access::sample> texture [[texture(0)]])
{
    constexpr sampler s(coord::normalized,
                        address::clamp_to_zero,
                        filter::linear);
    
    float4 tex_color = texture.sample(s, in.texture_coord);
    float4 bac_color = in.color;
    
    if (tex_color[3] == 1 || tex_color[3] == 0)
        return bac_color;
    
    return tex_color;
}