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
#import "metalCustomTexture.h"
#import "Renderer.h"
#import "metal3DPosition.h"
#import "SharedStructures.h"

#include "Camera.hpp"
#include <vector>

static const float t = 1.f, s = 0.f;
static const simd::float2 textureArrayData[] =
{
    { s, s },
    { t - s, s},
    { t - s, t - s},
    { s, t - s},
    
    {2.f, 0.f},
    {2.f, 1.f},
    {2.f, 2.f},
    {1.f, 2.f},
    {0.f, 2.f}
};

@implementation GameViewController
{
    // view
    MTKView *_view;
    
    // renderer
    Renderer* _renderer;
    
    metalCustomGeometry* _grid;
    metalCustomGeometry* _plane;
    
    metalCustomGeometry* _textured_geometry;
    metalCustomGeometry* _clear_geoemtry;
    
    metalCustomTexture* _textureHandler;
    
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
    
    // do geometry
    metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
    metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
    
    NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
    NSURL *planeURL = [[NSBundle mainBundle] URLForResource:@"tr" withExtension:@"obj"];
    if (gridURL == nil || planeURL == nil)
        NSLog(@"Sorry. File not found");
    
    _grid = [[metalCustomGeometry alloc] initWithDevice:_device andLoadFrom:gridURL];
    _plane =[[metalCustomGeometry alloc] initWithDevice:_device andLoadFrom:planeURL];
    
    _textured_geometry = _grid;
    _clear_geoemtry = _plane;
    
    [_grid setSpacePosition:position1];
    [_plane setSpacePosition:position2];
    
    _camera.move( {0.f, 0.f, -5.f} );
    
    metalGPBlueBox* box = [[metalGPBlueBox alloc] initWithDevice:_device];
    [_renderer initPipelineState:[box vertexDescriptor]];
    
    [self _recalculateProjection];
    
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    [_plane setViewProjection:&viewProj];
    [_grid setViewProjection:&viewProj];
    [_plane update];
    [_grid update];
    
    // do texture
    std::vector<simd::float4> purePositions;
    purePositions.reserve(_textured_geometry.vertexCount);
    
    simd::float4* v = (simd::float4*) [_textured_geometry.vertexBuffer contents];
    
    for (auto i=0; i < 2 * _textured_geometry.vertexCount; i += 2)
    {
        purePositions.push_back(v[i]);
    }
    
    _textureHandler = [[metalCustomTexture alloc] initWithDevice:_device
                                                        Vertices:purePositions
                                                      andPicture:@"Image008"];
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
        
        [_renderer drawWithGeometry:_clear_geoemtry];
        
        [_renderer drawWithGeometry:_textured_geometry texture:_textureHandler];
        
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
    [self _recalculateProjection];
}

- (void)_recalculateProjection
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    _projectionMatrix = matrix_from_perspective_fov_aspectLH(65.0f * (M_PI / 180.0f), aspect, 0.1f, 100.0f);
}

- (void)_update
{
    [_plane.spacePosition rotateWithAxis:(vector_float3){0.f, 0.0f, 1.f} andAngle:0.02];
    
    [_plane update];
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
