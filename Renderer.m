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
    MTKView*                _view;
    
    id <MTLDevice>              _device;
    id <MTLCommandQueue>        _commandQueue;
    id <MTLLibrary>             _defaultLibrary;
    
    NSMutableArray* _arrPipelineStates;
    
    id <MTLDepthStencilState>   _depthState;
    
    id<MTLCommandBuffer>        _commandBuffer;
    id<MTLRenderCommandEncoder> _commandEncoder;
    
    MTLRenderPassDescriptor* _renderPass;
    
    NSUInteger _textureCounter;
}

- (id<MTLDevice>)getDevice
{
    return _device;
}

- (instancetype)initWithView:(MTKView*)view
{
    if (self = [super init])
    {
        _device = MTLCreateSystemDefaultDevice();
        if (!_device)
            NSLog(@"Unnable to create device, guys");
        
        _defaultLibrary = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
        
        _view = view;
        
        _view.device = [self getDevice];
        
        _view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
        
        _arrPipelineStates = [[NSMutableArray alloc] init];
        _textureCounter = 0;
    }
    
    return self;
}

- (void)createPipelineStatesArray:(MTLRenderPipelineDescriptor*)desc
{
    NSString* vertBase = @"lighting_vertex";
    NSString* fragBase = @"lighting_fragment";
    
    for (int i=0; i<4; ++i)
    {
        NSNumber* num = [NSNumber numberWithInt:i];
        NSString* vert = [vertBase stringByAppendingString:[num stringValue]];
        NSString* frag = [fragBase stringByAppendingString:[num stringValue]];
        
        desc.vertexFunction = [_defaultLibrary newFunctionWithName:vert];
        desc.fragmentFunction = [_defaultLibrary newFunctionWithName:frag];
        
        NSError *error = NULL;
        id <MTLRenderPipelineState> rps = [_device newRenderPipelineStateWithDescriptor:desc error:&error];
        if (!rps) {
            NSLog(@"Failed to created second pipeline state, %@", error);
        }
        [_arrPipelineStates addObject:rps];
    }
}

- (void)initPipelineState:(MTLVertexDescriptor*)vertDesc
{
    // Create a vertex descriptor from the MTKMesh
    MTLVertexDescriptor *vertexDescriptor = vertDesc; //[MTLVertexDescriptor vertexDescriptor];
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    // Create a reusable pipeline state
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.vertexDescriptor = vertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    
    [self createPipelineStatesArray:pipelineStateDescriptor];
    
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

- (void)startFrame
{
    MTLRenderPassDescriptor* renderPassDescriptor = _view.currentRenderPassDescriptor;
    
    if(renderPassDescriptor == nil) // If we have a valid drawable, begin the commands to render into it
    {
        NSLog(@"Bad renderPassDescriptor/drawable");
        return;
    }
    
    _textureCounter = 0;
    
    _commandBuffer = [_commandQueue commandBuffer];
    _commandEncoder = [_commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [_commandEncoder setDepthStencilState:_depthState];
    
    // Set context state
    [_commandEncoder pushDebugGroup:@"DrawCube"];
}

- (void)addTexture:(id<metalTextureProviderProtocol>)textureProvider
{
    [_commandEncoder setVertexBuffer:textureProvider.bufferCoords offset:0 atIndex:2 + _textureCounter];
    [_commandEncoder setFragmentTexture:textureProvider.dataMipMap atIndex:_textureCounter];
    
    ++_textureCounter;
}

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
{
    [_commandEncoder setRenderPipelineState:[_arrPipelineStates objectAtIndex:_textureCounter]];
    
    [_commandEncoder setVertexBuffer:[geometryProvider vertexBuffer]
                              offset:0
                             atIndex:0 ];
    
    [_commandEncoder setVertexBuffer:geometryProvider.uniformBuffer offset:0 atIndex:1 ];
    
    // Tell the render context we want to draw our primitives
    [_commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                indexCount:[geometryProvider indexCount]
                                 indexType:MTLIndexTypeUInt16
                               indexBuffer:[geometryProvider indexBuffer]
                         indexBufferOffset:0];
    
    _textureCounter = 0;
}

- (void)endFrame
{
    [_commandEncoder endEncoding];
    
    id<CAMetalDrawable> drawable = _view.currentDrawable;
    assert(drawable != nil);
    
    [_commandBuffer presentDrawable:drawable];
    [_commandBuffer commit];

}


@end
