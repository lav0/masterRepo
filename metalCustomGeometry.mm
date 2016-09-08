//
//  metalCustomGeometry.m
//  masterOfPuppets
//
//  Created by Andrey on 12.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalCustomGeometry.h"
#import "OBJModel.h"
#import "linkedGeometry.hpp"
#import "convertFunctionsRcb.h"

static const float c = 1.f, n = -1.f;
static const float vertexData[] =
{
    c, 0.f, 0.f, 1.f,   0.f, 0.f, n, 0.f,
    0.f, c, 0.f, 1.f,   0.f, 0.f, n, 0.f,
    0.f, 0.f, 0.f,1.f,  0.f, 0.f, n, 0.f
};

static const IndexType indexData[] =
{
    0, 1, 2
};

@implementation metalCustomGeometry
{
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _uniformBuffer;
    id<MTLBuffer> _indexBuffer;
    
    std::unique_ptr<spacePosition3D> _spacePosition3D;
    matrix_float4x4 _viewProjectionMatrix;
    
    linkedGeometry* _linkedGeo;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        _vertexCount   = 3;
        _indexCount    = 3;
        _vertexBuffer  = [device newBufferWithBytes:vertexData length:sizeof(vertexData) options:0];
        _indexBuffer   = [device newBufferWithBytes:indexData length:sizeof(indexData) options:0];
        
        _uniformBuffer = [device newBufferWithLength:sizeof(uniforms_t) options:0];
        
        vector_float3 v = {0.f, 0.f, 0.f};
        _spacePosition3D = std::unique_ptr<spacePosition3D>(new spacePosition3D(v));
        
        [self linkGeometryAndBuffers:_vertexCount :_indexCount];
    }
    
    return self;
}


- (instancetype)initWithDevice:(id<MTLDevice>)device andLoadFrom:(NSURL*)source
{
    if (self = [super init])
    {
        [self loadModel:device from:source];
        
        _uniformBuffer = [device newBufferWithLength:sizeof(uniforms_t) options:0];
        
        vector_float3 v = {0.f, 0.f, 0.f};
        _spacePosition3D = std::unique_ptr<spacePosition3D>(new spacePosition3D(v));
        
        [self linkGeometryAndBuffers:_vertexCount :_indexCount];
    }
    
    return self;
}

- (void)linkGeometryAndBuffers:(size_t)vertCount :(size_t)indCount
{
    _linkedGeo = new linkedGeometry(
                                    (Vertex*)   [_vertexBuffer contents], vertCount,
                                    (IndexType*)[_indexBuffer contents], indCount
                                    );
}

- (void)loadModel:(id<MTLDevice>)device from:(NSURL*)source
{
    OBJModel *teapot = [[OBJModel alloc] initWithContentsOfURL:source];
    
    OBJGroup *baseGroup = [teapot groupAtIndex:1];
    
    if (baseGroup)
    {
        _vertexCount = baseGroup->vertexCount;
        _indexCount = baseGroup->indexCount;
        
        _vertexBuffer = [device newBufferWithBytes:baseGroup->vertices
                                            length:sizeof(Vertex) * _vertexCount
                                           options:0];
        _indexBuffer = [device newBufferWithBytes:baseGroup->indices
                                            length:sizeof(IndexType) * _indexCount
                                          options:0];
    }
}

- (void)update
{
    uniforms_t *content = (uniforms_t*)[_uniformBuffer contents];
    
    matrix_float4x4 model = _spacePosition3D->getTransformation();
    
    content->normal_matrix = matrix_invert(matrix_transpose(model));
    content->modelview_projection_matrix = matrix_multiply(_viewProjectionMatrix, model);
}

- (void)setViewProjection:(matrix_float4x4*)viewProjection
{
    _viewProjectionMatrix = *viewProjection;
}

@synthesize vertexCount = _vertexCount;
- (size_t)vertexCount
{
    return _vertexCount;
}

@synthesize indexCount = _indexCount;
- (size_t)indexCount
{
    return _indexCount;
}

- (spacePosition3D)spacePosition3D
{
    return *(_spacePosition3D.get());
}
- (void)setSpacePosition3D:(const spacePosition3D&)position
{
    *(_spacePosition3D.get()) = position;
}

- (id<MTLBuffer>)vertexBuffer
{
    return _vertexBuffer;
}

- (id<MTLBuffer>)uniformBuffer
{
    return _uniformBuffer;
}

- (id<MTLBuffer>)indexBuffer
{
    return _indexBuffer;
}

- (Vertex*)getClosestToAim4D:(const simd::float4&)aim
{
    if (nullptr != _linkedGeo)
        return _linkedGeo->getClosestTo(aim);
    
    return nullptr;
}
- (Vertex*)getClosestToAim3D:(const simd::float3&)aim
{
    if (nullptr != _linkedGeo)
        return _linkedGeo->getClosestTo(aim);
    
    return nullptr;
}

- (BOOL)touchedWithRayOrigin:(const rcbVector3D&)ray_origin
                andDirection:(const rcbUnitVector3D&)direction
                   touchedAt:(vector_float4&)result
{
    auto trs = _spacePosition3D->getTransformation();
    _linkedGeo->updateModelTransformation(&trs);
    
    rcbVector3D vc;
    
    BOOL intersected = _linkedGeo->intersectionWithRay(ray_origin, direction, &vc);
    
    if (intersected)
    {
        auto inverted = matrix_invert(trs);
        vector_float4 v = mop::convertFromRcbToSimdPos(vc);
        
        result = matrix_multiply(inverted, v);
    }
    
    return intersected;
}


@end
