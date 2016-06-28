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
#import "metalCustomGeometry.h"
#import "Renderer.h"
#import "metal3DPosition.h"
#import "SharedStructures.h"
#import "MBETextureLoader.h"

#include "Camera.hpp"

static const float t = 1.f, s = -0.2f;
static const float textureArrayData[] =
{
    s, s,
    t - s, s,
    t - s, t - s,
    s, t - s
};

@implementation GameViewController
{
    // view
    MTKView *_view;
    
    // renderer
    Renderer* _renderer;
    
    metalCustomGeometry* _grid;
    metalCustomGeometry* _plane;
    
    id<MTLBuffer>   _textureBuffer;
    id<MTLTexture>  _textureData;
    
    Camera          _camera;
    
    // uniforms
    matrix_float4x4 _projectionMatrix;
    
    float _rotation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _renderer = [[Renderer alloc] init];
    
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
    
//    metal3DPosition* position = [[metal3DPosition alloc] initAtPoint:(vector_float3){-7.f, 0.f, 4.f}];
//    metal3DPosition* position0 = [[metal3DPosition alloc] initAtPoint:(vector_float3){7.f, 0.f, 4.f}];
    metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
    metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
    
//    _box = [[metalGPBlueBox alloc] initWithDevice:_device andPosition:position];
//    _box0 = [[metalGPBlueBox alloc] initWithDevice:_device andPosition:position0];
    
    NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"sgrid" withExtension:@"obj"];
    NSURL *planeURL = [[NSBundle mainBundle] URLForResource:@"tr" withExtension:@"obj"];
    if (gridURL == nil || planeURL == nil)
        NSLog(@"Sorry. File not found");
    
    _grid = [[metalCustomGeometry alloc] initWithDevice:_device andLoadFrom:gridURL];
    _plane =[[metalCustomGeometry alloc] initWithDevice:_device andLoadFrom:planeURL];
    
    [_grid setSpacePosition:position1];
    [_plane setSpacePosition:position2];
    
    _camera.move( {0.f, 0.f, -5.f} );
    
    metalGPBlueBox* box = [[metalGPBlueBox alloc] initWithDevice:_device];
    [_renderer initPipelineState:[box vertexDescriptor]];
    
    _textureBuffer = [_device newBufferWithBytes:textureArrayData
                                          length:sizeof(textureArrayData)
                                         options:0];
    
    _textureData = [MBETextureLoader texture2DWithImageNamed:@"Image008" device:_device];
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
        
        [_renderer drawWithGeometry:_grid];
        
        [_renderer setTextureBuffer:_textureBuffer andTextureData:_textureData];
        [_renderer drawWithGeometry:_plane];
        
        [_renderer endFrame:_view.currentDrawable];
        
        //[_renderer0 startFrame:renderPassDescriptor];
        
        //[_renderer0 endFrame:_view.currentDrawable];
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
    //[_plane.spacePosition rotateWithAxis:(vector_float3){0.7f, 0.7f, 0.f} andAngle:0.1];
    [_grid.spacePosition rotateWithAxis:(vector_float3){0.f, 0.0f, 1.f} andAngle:0.02];
    
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    [_plane setViewProjection:&viewProj];
    [_grid setViewProjection:&viewProj];
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
