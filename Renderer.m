//
//  Renderer.m
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "Renderer.h"
#import "SharedStructures.h"

@implementation Renderer
{
    id <MTLDevice>              _device;
    id <MTLCommandQueue>        _commandQueue;
    id <MTLLibrary>             _defaultLibrary;
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLRenderPipelineState> _pipelineState0;
    
    id <MTLDepthStencilState>   _depthState;
    
    id<MTLCommandBuffer>        _commandBuffer;
    id<MTLRenderCommandEncoder> _commandEncoder;
    
    MTLRenderPassDescriptor* _renderPass;
}

- (id<MTLDevice>)getDevice
{
    return _device;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _device = MTLCreateSystemDefaultDevice();
        if (!_device)
            NSLog(@"Unnable to create device, guys");
        
        _defaultLibrary = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
    }
    
    return self;
}

- (void)initPipelineState:(MTLVertexDescriptor*)vertDesc
{
    // Load the fragment program into the library
    id <MTLFunction> fragmentProgram = [_defaultLibrary newFunctionWithName:@"lighting_fragment"];
    
    // Load the vertex program into the library
    id <MTLFunction> vertexProgram = [_defaultLibrary newFunctionWithName:@"lighting_vertex"];
    
    // Create a vertex descriptor from the MTKMesh
    MTLVertexDescriptor *vertexDescriptor = vertDesc; //[MTLVertexDescriptor vertexDescriptor];
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    // Create a reusable pipeline state
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.vertexFunction = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    pipelineStateDescriptor.vertexDescriptor = vertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
    
    pipelineStateDescriptor.vertexFunction = [_defaultLibrary newFunctionWithName:@"lighting_vertex0"];
    pipelineStateDescriptor.fragmentFunction = [_defaultLibrary newFunctionWithName:@"lighting_fragment0"];
    _pipelineState0 = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState0) {
        NSLog(@"Failed to created second pipeline state, %@", error);
    }
    
    _renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
    //self.renderPass.colorAttachments[0].texture = framebufferTexture;
    _renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.9, 0.9, 0.9, 1);
    _renderPass.colorAttachments[0].storeAction = MTLStoreActionStore;
    _renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    [self initDepthStencilState];
}

- (void)initDepthStencilState
{
    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
}

- (void)startFrame:(MTLRenderPassDescriptor*)passDesc
{
    _commandBuffer = [_commandQueue commandBuffer];
    _commandEncoder = [_commandBuffer renderCommandEncoderWithDescriptor:passDesc];
    [_commandEncoder setDepthStencilState:_depthState];
    
    // Set context state
    [_commandEncoder pushDebugGroup:@"DrawCube"];
    [_commandEncoder setRenderPipelineState:_pipelineState];
}

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
           uniformBuffer:(id<MTLBuffer>)uniformBuffer
{
    [_commandEncoder setVertexBuffer:[geometryProvider vertexBuffer]
                              offset:0
                             atIndex:0 ];
    
    [_commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1 ];
    
    // Tell the render context we want to draw our primitives
    [_commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                indexCount:[geometryProvider indexCount]
                                 indexType:MTLIndexTypeUInt16
                               indexBuffer:[geometryProvider indexBuffer]
                         indexBufferOffset:0];
    
    [_commandEncoder setRenderPipelineState:_pipelineState0];
}

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
{
    [self drawWithGeometry:geometryProvider uniformBuffer:geometryProvider.uniformBuffer];
}

- (void)endFrame:(id<CAMetalDrawable>)drawable
{
    [_commandEncoder endEncoding];
    
    assert(drawable != nil);
    
    [_commandBuffer presentDrawable:drawable];
    [_commandBuffer commit];

}

- (void)setTextureBuffer:(id<MTLBuffer>)textureBuffer andTextureData:(id<MTLTexture>)textureData
{
    [_commandEncoder setVertexBuffer:textureBuffer offset:0 atIndex:2];
    [_commandEncoder setFragmentTexture:textureData atIndex:0];
    
}

@end
