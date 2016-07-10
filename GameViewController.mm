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
    
    _textureData = [MBETextureLoader texture2DWithImageNamed:@"Image008" device:_device];
    
    [self _generateTextureCoords];
}

- (void)_transformToTextureCoords:(simd::float4&)vertexBase0
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
    
    float angle1 = atan2f(simd::cross(a, b)[2], simd::dot(a, b));
    
    simd::float2 c1 = {cosf(angle1), sinf(angle1)};
    simd::float2 c2 = {-sinf(angle1), cosf(angle1)};
    simd::float2x2 m = {c1, c2};
    
    float a_norm = simd::length(a);
    float b_norm = simd::length(b);
    
    m = m * (b_norm / a_norm);
    
    auto f_ = [&m, &x0, &u0](float x, float y)
    {
        return u0 + m * ( (simd::float2){x, y} - x0);
    };
    
    simd::float4* v = (simd::float4*) [_textured_geometry.vertexBuffer contents];
    
    for (auto i=0; i < 2 * _textured_geometry.vertexCount; i += 2)
    {
        simd::float4 point = v[i];
        simd::float2 coord = f_(point[0], point[1]);
        
        result.push_back(coord);
    }
}

- (void)_generateTextureCoords
{
    std::vector<simd::float2> textureCoords;
    
    simd::float4* v = (simd::float4*) [_textured_geometry.vertexBuffer contents];
    
    float        scale = 1.f;
    float        angle = 0.f; // 3.14 / 4.f;
    simd::float2 shift = {0.f, 0.0f};
    
    simd::float2x2 mat ( (simd::float2){cosf(angle), -sinf(angle)}, (simd::float2){sinf(angle), cosf(angle)} );
    mat = scale * mat;
    
    simd::float2 u0 = {0.f, 0.f};  // the texture coordinates
    simd::float2 u1 = {1.f, 1.f};  // (u, v)
    
    [self _transformToTextureCoords:v[4]
                              base2:v[12]
                     toTextureBase1:u0
                              base2:u1
                             output:textureCoords];
    
    _textureBuffer = [_renderer.getDevice newBufferWithBytes:textureCoords.data()
                                                      length:sizeof(simd::float2) * textureCoords.size()
                                                     options:0];
    
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
        
        [_renderer setTextureBuffer:_textureBuffer andTextureData:_textureData];
        [_renderer drawWithGeometry:_textured_geometry];
        
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
    [_plane.spacePosition rotateWithAxis:(vector_float3){0.f, 0.0f, 1.f} andAngle:0.02];
    
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
