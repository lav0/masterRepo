//
//  GameViewController.m
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright (c) 2016 Andrey. All rights reserved.
//

#import "GameViewController.h"
#import <Metal/Metal.h>
#import <simd/simd.h>

#import "metalGPBlueBox.h"
#import "Renderer.h"
#import "metal3DPosition.h"
#import "SharedStructures.h"

#include "Camera.hpp"

@implementation GameViewController
{
    // view
    MTKView *_view;
    
    // renderer
    Renderer* _renderer;
    
    metalGPBlueBox* _box;
    id<MTLBuffer>   _uniform;
    
    metalGPBlueBox* _box0;
    id<MTLBuffer>   _uniform0;
    
    Camera          _camera;
    
    // uniforms
    matrix_float4x4 _projectionMatrix;
    
    float _rotation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _renderer = [[Renderer alloc] initWithLayer:(CAMetalLayer *)self.view.layer];
    
    [self _setupView];
    
    [self _loadAssets];
    
    [self _reshape];
}

- (void)_setupView
{
    _view = (MTKView *)self.view;
    _view.delegate = self;
    _view.device = [_renderer getDevice];
    
    _view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
}

- (void)_loadAssets
{
    id<MTLDevice> _device = [_renderer getDevice];
    
    metal3DPosition* position = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
    metal3DPosition* position0 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
    [position0 rotateWithAxis:{1.f, 0.f, 0.f} andAngle:0.5];
    
    _box = [[metalGPBlueBox alloc] initWithDevice:_device andPosition:position];
    _box0 = [[metalGPBlueBox alloc] initWithDevice:_device andPosition:position0];
    
    _camera.move( {0.f, 0.f, -5.f} );
    
    _uniform = [_device newBufferWithLength:sizeof(uniforms_t) options:0];
    _uniform0 = [_device newBufferWithLength:sizeof(uniforms_t) options:0];
    
    [_renderer initPipelineState:[_box vertexDescriptor]];
}

- (void)_render
{
    [self _update];

    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor* renderPassDescriptor = _view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil) // If we have a valid drawable, begin the commands to render into it
    {
        // Create a render command encoder so we can render into something
        [_renderer startFrame:renderPassDescriptor];
        
        [_renderer drawWithGeometry:_box];
        [_renderer drawWithGeometry:_box0];
        
        [_renderer endFrame:_view.currentDrawable];
    }
    else
    {
        NSLog(@"Bad renderPassDescriptor/drawable");
    }
}

- (void)_reshape
{
    // When reshape is called, update the view and projection matricies since this means the view orientation or size changed
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    _projectionMatrix = matrix_from_perspective_fov_aspectLH(65.0f * (M_PI / 180.0f), aspect, 0.1f, 100.0f);
}

- (void)_update
{
    [_box.spacePosition rotateWithAxis:(vector_float3){0.7f, 0.7f, 0.f} andAngle:0.1];
    
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    [_box setViewProjection:&viewProj];
    [_box0 setViewProjection:&viewProj];
}

// Called whenever view changes orientation or layout is changed
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    [self _reshape];
}


// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view
{
    @autoreleasepool {
        [self _render];
    }
}

@end
