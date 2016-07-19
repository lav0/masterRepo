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
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
                    andPicture:(NSString*)fileName
{
    if (self = [super init])
    {
        _theVertices = vertices;
        
        [self _prepareBufferWithDevice:device];
        
        simd::float4 tenacity0 = {2.f, 0.f, 0.f, 1.f};
        simd::float4 tenacity1 = {0.f, 0.f, 0.f, 1.f};
        
        [self transformTextureAccordingWith:tenacity0
                                         And:tenacity1];
        
        _dataMipMap = [MBETextureLoader texture2DWithImageNamed:fileName device:device];
    }
    
    return self;
}

- (id<MTLBuffer>)bufferCoords
{
    return _bufferCoords;
}
- (id<MTLTexture>)dataMipMap
{
    return _dataMipMap;
}
- (void)transformTextureAccordingWith:(simd::float4&)vertexBase0
                                   And:(simd::float4&)vertexBase1
{
    //// pick the base points to determine transformation from vectex system to texture one:
    //// (x,y) -> (u,v)
    //// vertexBase0 -> u0
    simd::float2 x0 = { vertexBase0[0], vertexBase0[1] };  // these are (x, y)
    simd::float2 x1 = { vertexBase1[0], vertexBase1[1] };  // coordinates
    
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
