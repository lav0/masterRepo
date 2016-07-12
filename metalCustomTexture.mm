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
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
                    andPicture:(NSString*)fileName
{
    if (self = [super init])
    {
        [self _generateTextureCoords:vertices device:device];
        
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
- (void)_transformToTextureCoords:(std::vector<simd::float4>)vertices
                            base1:(simd::float4&)vertexBase0
                            base2:(simd::float4&)vertexBase2
                   toTextureBase1:(simd::float2&)u0
                            base2:(simd::float2&)u1
                           output:(std::vector<simd::float2>&)result
{
    //// pick the base points to determine transformation from vectex system to texture one:
    //// (x,y) -> (u,v)
    //// vertexBase0 -> u0
    simd::float2 x0 = { vertexBase0[0], vertexBase0[1] };  // these are (x, y)
    simd::float2 x1 = { vertexBase2[0], vertexBase2[1] };  // coordinates
    
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
    
    for (auto point : vertices)
    {
        simd::float2 coord = f_(point[0], point[1]);
        
        result.push_back(coord);
    }
}

- (void)_generateTextureCoords:(std::vector<simd::float4>) vertices
                        device:(id<MTLDevice>) device
{
    std::vector<simd::float2> textureCoords;
    
    //simd::float4* v = (simd::float4*) [vertexBuffer contents];
    
    float        scale = 1.f;
    float        angle = 0.f; // 3.14 / 4.f;
    simd::float2 shift = {0.f, 0.0f};
    
    simd::float2x2 mat ( (simd::float2){cosf(angle), -sinf(angle)}, (simd::float2){sinf(angle), cosf(angle)} );
    mat = scale * mat;
    
    simd::float2 u0 = {0.f, 0.f};  // the texture coordinates
    simd::float2 u1 = {1.f, 1.f};  // (u, v)
    
    [self _transformToTextureCoords:vertices
                              base1:vertices[0]
                              base2:vertices[2]
                     toTextureBase1:u0
                              base2:u1
                             output:textureCoords];
    
    _bufferCoords = [device newBufferWithBytes:textureCoords.data()
                                        length:sizeof(simd::float2) * textureCoords.size()
                                       options:0];
    
}

@end
