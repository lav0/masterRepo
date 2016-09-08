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
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        MDLMesh *mdl = [MDLMesh newBoxWithDimensions:(vector_float3){1.5,1.5,1.5} segments:(vector_uint3){1,1,1}
                                        geometryType:MDLGeometryTypeTriangles inwardNormals:NO
                                           allocator:[[MTKMeshBufferAllocator alloc] initWithDevice:device]];
        
        _boxMesh = [[MTKMesh alloc] initWithMesh:mdl device:device error:nil];
    }
    
    return self;
}

- (MTLVertexDescriptor*)vertexDescriptor
{
    return MTKMetalVertexDescriptorFromModelIO(_boxMesh.vertexDescriptor);
}




@end
