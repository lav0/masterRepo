//
//  metalGPBlueBox.m
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalGPBlueBox.h"
#import "SharedStructures.h"
#import <MetalKit/MetalKit.h>

@implementation metalGPBlueBox
{
    MTKMesh *_boxMesh;
    
    id<MTLBuffer> _uniformBuffer;
}

@synthesize spacePosition = _position;

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        MDLMesh *mdl = [MDLMesh newBoxWithDimensions:(vector_float3){2,2,2} segments:(vector_uint3){1,1,1}
                                        geometryType:MDLGeometryTypeTriangles inwardNormals:NO
                                           allocator:[[MTKMeshBufferAllocator alloc] initWithDevice:device]];
        
        _boxMesh = [[MTKMesh alloc] initWithMesh:mdl device:device error:nil];
        
        _uniformBuffer = [device newBufferWithLength:sizeof(uniforms_t) options:0];
    }
    
    return self;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device andPosition:(metal3DPosition*)position
{
    self = [[metalGPBlueBox alloc] initWithDevice:device];
    
    [self setSpacePosition:position];
    
    return self;
}

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

- (MTLVertexDescriptor*)vertexDescriptor
{
    return MTKMetalVertexDescriptorFromModelIO(_boxMesh.vertexDescriptor);
}

- (id<MTLBuffer>)vertexBuffer
{
    return _boxMesh.vertexBuffers[0].buffer;
}

- (id<MTLBuffer>)uniformBuffer
{
//    uniforms_t *box_trs = (uniforms_t *)[_uniformBuffer contents];
//    
//    matrix_float4x4 model = [self.spacePosition getTransformation];
//    
//    box_trs->normal_matrix = matrix_invert(matrix_transpose(model));
//    box_trs->modelview_projection_matrix = model;
    
    return _uniformBuffer;
}

- (id<MTLBuffer>)indexBuffer
{
    return _boxMesh.submeshes[0].indexBuffer.buffer;
}

- (size_t)indexCount
{
    return _boxMesh.submeshes[0].indexCount;
}

- (void)setViewProjection:(matrix_float4x4*)viewProjection
{
    uniforms_t *content = (uniforms_t*)[_uniformBuffer contents];
    
    matrix_float4x4 model = [self.spacePosition getTransformation];
    
    content->normal_matrix = matrix_invert(matrix_transpose(model));
    content->modelview_projection_matrix = matrix_multiply(*viewProjection, model);
}


@end
