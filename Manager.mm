//
//  Manager.m
//  masterOfPuppets
//
//  Created by Andrey on 20.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "Manager.h"
#import "metalGPBlueBox.h"
#import "metalCustomGeometry.h"
#import "metalCustomTexture.h"

#include "Camera.hpp"
#include <vector>

@implementation Manager
{
    metalCustomGeometry* _grid;
    metalCustomGeometry* _plane;
    
    metalCustomGeometry* _textured_geometry;
    metalCustomGeometry* _clear_geoemtry;
    
    metalCustomTexture* _textureHandler;
    
    Camera          _camera;
    
    matrix_float4x4 _projectionMatrix;
    
    float _rotation;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        // do geometry
        metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
        metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
        
        NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
        NSURL *planeURL = [[NSBundle mainBundle] URLForResource:@"tr" withExtension:@"obj"];
        if (gridURL == nil || planeURL == nil)
            NSLog(@"Sorry. File not found");
        
        _grid = [[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:gridURL];
        _plane =[[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:planeURL];
        
        _textured_geometry = _grid;
        _clear_geoemtry = _plane;
        
        [_grid setSpacePosition:position1];
        [_plane setSpacePosition:position2];
        
        _camera.move( {0.f, 0.f, -5.f} );
        
        // do texture
        std::vector<simd::float4> purePositions;
        purePositions.reserve(_textured_geometry.vertexCount);
        
        simd::float4* v = (simd::float4*) [_textured_geometry.vertexBuffer contents];
        
        for (auto i=0; i < 2 * _textured_geometry.vertexCount; i += 2)
        {
            purePositions.push_back(v[i]);
        }
        
        _textureHandler = [[metalCustomTexture alloc] initWithDevice:device
                                                            Vertices:purePositions
                                                          andPicture:@"Image008"];
        _rotation = 0.f;
    }
    
    return self;
}

- (void)recalculateProjectionWithWidth:(CGFloat)width AndHeight:(CGFloat)height
{
    float aspect = fabs(width / height);
    _projectionMatrix = matrix_from_perspective_fov_aspectLH(65.0f * (M_PI / 180.0f), aspect, 0.1f, 100.0f);
    
    [self _updateViewProjection];
}

- (void)_updateViewProjection
{
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    [_plane setViewProjection:&viewProj];
    [_grid setViewProjection:&viewProj];
    
    [_plane update];
    [_grid update];
}

- (void)update
{
    [_plane.spacePosition rotateWithAxis:(vector_float3){0.f, 0.0f, 1.f} andAngle:0.02];
    
    [_plane update];
    
    float tx = cosf(_rotation);
    float ty = sinf(_rotation);
    
    simd::float4 tenacity0 = {1.f + tx, 0.f, 0.f, 1.f};
    simd::float4 tenacity1 = {tx, ty, 0.f, 1.f};
    
    [_textureHandler transformTextureAccordingWith:tenacity0 And:tenacity1];
    
    _rotation += 0.01f;
}

- (id<metalGeometryProviderProtocol>)getGeometry0
{
    return _clear_geoemtry;
}
- (id<metalGeometryProviderProtocol>)getGeometry1
{
    return _textured_geometry;
}
- (id<metalTextureProviderProtocol>)getTexture;
{
    return _textureHandler;
}

@end
