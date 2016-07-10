//
//  metalCustomGeometry.m
//  masterOfPuppets
//
//  Created by Andrey on 12.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalCustomGeometry.h"
#import "SharedStructures.h"
#import "OBJModel.h"

typedef uint16_t IndexType;

static const float c = 2.f, n = -1.f;
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
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        _vertexCount   = 3;
        _vertexBuffer  = [device newBufferWithBytes:vertexData length:sizeof(vertexData) options:0];
        _indexBuffer   = [device newBufferWithBytes:indexData length:sizeof(indexData) options:0];
        
        _uniformBuffer = [device newBufferWithLength:sizeof(uniforms_t) options:0];
    }
    
    return self;
}


- (instancetype)initWithDevice:(id<MTLDevice>)device andLoadFrom:(NSURL*)source
{
    if (self = [super init])
    {
        [self loadModel:device from:source];
        
        _uniformBuffer = [device newBufferWithLength:sizeof(uniforms_t) options:0];
    }
    
    return self;
}

- (void)loadModel:(id<MTLDevice>)device from:(NSURL*)source
{
    OBJModel *teapot = [[OBJModel alloc] initWithContentsOfURL:source];
    
    OBJGroup *baseGroup = [teapot groupAtIndex:1];
    
    if (baseGroup)
    {
        _vertexCount = baseGroup->vertexCount;
        _vertexBuffer = [device newBufferWithBytes:baseGroup->vertices
                                            length:sizeof(Vertex) * _vertexCount
                                           options:0];
        _indexBuffer = [device newBufferWithBytes:baseGroup->indices
                                            length:sizeof(IndexType) * baseGroup->indexCount
                                          options:0];
    }
}

@synthesize vertexCount = _vertexCount;
- (size_t)vertexCount
{
    return _vertexCount;
}
- (void)setVertexCount:(size_t)vertexCount
{
    _vertexCount = vertexCount;
}

@synthesize spacePosition = _position;
- (metal3DPosition*)spacePosition
{
    if (_position == nil)
    {
        _position = [[metal3DPosition alloc] initAtPoint:(vector_float3){0.f, 0.f, 0.f}];
    }
    
    return _position;
}
- (void)setSpacePosition:(metal3DPosition *)position
{
    _position = position;
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

- (size_t)indexCount
{
    return _indexBuffer.length / sizeof(IndexType);
}

- (void)setViewProjection:(matrix_float4x4*)viewProjection
{
    uniforms_t *content = (uniforms_t*)[_uniformBuffer contents];
    
    matrix_float4x4 model = [self.spacePosition getTransformation];
    
    content->normal_matrix = matrix_invert(matrix_transpose(model));
    content->modelview_projection_matrix = matrix_multiply(*viewProjection, model);
}


@end
