//
//  metalCustomTexture.m
//  masterOfPuppets
//
//  Created by Andrey on 12.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalCustomTexture.h"
#import "MBETextureLoader.h"

#include <vector>

@implementation metalCustomTexture
{
    id<MTLBuffer> _bufferCoords;
    id<MTLTexture> _dataMipMap;
    
    std::vector<simd::float2*> _textureCoords;
    
    std::vector<simd::float4> _theVertices;
    
    simd::float3 _bind_point0;
    simd::float3 _bind_point1;
    
    int _caught_point;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
               andPictureNamed:(NSString*)fileName
{
    if (self = [super init])
    {
        _theVertices = vertices;
        
        [self _prepareBufferWithDevice:device];
        
        _bind_point0 = {2.f, 0.f, 0.f};
        _bind_point1 = {0.f, 0.f, 0.f};
        
        _caught_point = -1;
        
        [self transfromTextureWithBindPoints];
        
        _dataMipMap = [MBETextureLoader texture2DWithImageNamed:fileName device:device];
    }
    
    return self;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
                    andPicture:(THEIMAGE*)image
{
    if (self = [super init])
    {
        _theVertices = vertices;
        
        [self _prepareBufferWithDevice:device];
        
        _bind_point0 = {2.f, 0.f, 0.f};
        _bind_point1 = {0.f, 0.f, 0.f};
        
        [self transfromTextureWithBindPoints];
        
        _caught_point = -1;
        
        _dataMipMap = [MBETextureLoader texture2DWithImage:image device:device];
    }
    
    return self;
}

- (void)setBindPoints:(simd::float3&)bind0 :(simd::float3&)bind1;
{
    _bind_point0 = bind0;
    _bind_point1 = bind1;
}

- (bool)catchBindPointBy:(simd::float3)point
{
    float tol = 0.2;
    _caught_point = -1;
    
    if (vector_distance_squared(_bind_point0, point) < tol)
    {
        _caught_point = 0;
    }
    else if (vector_distance_squared(_bind_point1, point) < tol)
    {
        _caught_point = 1;
    }
    
    return _caught_point != -1;
}

- (bool)changeCaughtBindPointWith:(simd::float3)point
{
    if (_caught_point == -1)
        return NO;
    
    if (_caught_point == 0)
        _bind_point0 = point;
    else if (_caught_point == 1)
        _bind_point1 = point;
    else
        assert(false);
    
    [self transfromTextureWithBindPoints];
    
    return YES;
}

- (id<MTLBuffer>)bufferCoords
{
    return _bufferCoords;
}
- (id<MTLTexture>)dataMipMap
{
    return _dataMipMap;
}

- (simd::float2)transformWorld2ModelSurface:(simd::float3&)worldPoint
{
    return { worldPoint[0], worldPoint[1] };
}

- (void)transfromTextureWithBindPoints
{
    [self transformTextureAccordingWith:_bind_point0 And:_bind_point1];
}

- (void)transformTextureAccordingWith:(simd::float3&)vertexBase0
                                  And:(simd::float3&)vertexBase1
{
    //// pick the base points to determine transformation from vectex system to texture one:
    //// (x,y) -> (u,v)
    //// vertexBase0 -> u0
    simd::float2 x0 = [self transformWorld2ModelSurface:vertexBase0];  // these are (x, y)
    simd::float2 x1 = [self transformWorld2ModelSurface:vertexBase1];  // coordinates
    
    simd::float2 u0 = {0.f, 0.f};  // the texture coordinates
    simd::float2 u1 = {1.f, 1.f};  // (u, v)
    
    simd::float2 a = x1 - x0;
    simd::float2 b = u1 - u0;
    
    float angle = atan2f(simd::cross(a, b)[2], simd::dot(a, b));
    
    simd::float2 c1 = {cosf(angle), sinf(angle)};
    simd::float2 c2 = {-sinf(angle), cosf(angle)};
    simd::float2x2 m = {c1, c2};
    
    float a_norm = simd::length(a);
    float b_norm = simd::length(b);
    
    m = m * (b_norm / a_norm);
    
    auto f_ = [&m, &x0, &u0](float x, float y)
    {
        return u0 + m * ( (simd::float2){x, y} - x0);
    };
    
    for (auto i=0; i<_textureCoords.size(); ++i)
    {
        simd::float4 point = _theVertices[i];
        simd::float2 coord = f_(point[0], point[1]);
        
        *_textureCoords[i] = coord;
    }
}

- (void)_prepareBufferWithDevice:(id<MTLDevice>) device
{
    _bufferCoords = [device newBufferWithLength:sizeof(simd::float2) * _theVertices.size()
                                        options:0];
    
    simd::float2* content = (simd::float2*) [_bufferCoords contents];
    
    for (auto i=0; i<_theVertices.size(); ++i)
    {
        _textureCoords.push_back(&content[i]);
    }
}


@end
