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
#include "external/rcbPlaneForScreen.h"

#include <vector>

static const float DISTANCE_TO_PROJ_SCREEN = 1.f;

@implementation Manager
{
    NSMutableArray* _geometriesArray;
    NSMutableArray* _texturesArray;
    
    Camera          _camera;
    
    matrix_float4x4 _projectionMatrix;
    
    float           _rotation;
    unsigned int    _nextGeometryIndex;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        _geometriesArray = [[NSMutableArray alloc] init];
        _texturesArray   = [[NSMutableArray alloc] init];
        
        _camera.move( {0.f, 0.f, -5.f} );
        
        _rotation = 0.f;
        _nextGeometryIndex = 0;
        
        [self createGeometry:device];
        [self createTexture:device];
    }
    
    return self;
}

- (void)createGeometry:(id<MTLDevice>)device
{
    metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
    metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
    
    [position1 rotateWithAxis:{0.f, 1.f, 0.f} andAngle:0.9];
    
    NSURL *quadroURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
    NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"sgrid" withExtension:@"obj"];
    if (quadroURL == nil || gridURL == nil)
        NSLog(@"Sorry. File not found");
    
    metalCustomGeometry* g1 = [[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:quadroURL];
    metalCustomGeometry* g2 =[[metalCustomGeometry alloc] initWithDevice:device]; // andLoadFrom:gridURL];
    
    [g1 setSpacePosition:position1];
    [g2 setSpacePosition:position2];
    
    [_geometriesArray addObject:g1];
    [_geometriesArray addObject:g2];
}

- (void)createTexture:(id<MTLDevice>)device
{
    for (metalCustomGeometry* g in _geometriesArray)
    {
        auto purePositions = [Manager collectPositionsFrom:g];
        metalCustomTexture* t = [[metalCustomTexture alloc] initWithDevice:device
                                                                  Vertices:purePositions
                                                                andPicture:@"Image008"];
    
        [_texturesArray addObject:t];
    }
}

- (void)recalculateProjectionWithWidth:(CGFloat)width AndHeight:(CGFloat)height
{
    float aspect = fabs(width / height);
    _projectionMatrix = matrix_from_perspective_fov_aspectLH(65.0f * (M_PI / 180.0f),
                                                             aspect,
                                                             DISTANCE_TO_PROJ_SCREEN,
                                                             100.0f
                                                             );
    [self _updateViewProjection];
}

- (void)_updateViewProjection
{
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    for (metalCustomGeometry* g in _geometriesArray)
    {
        [g setViewProjection:&viewProj];
        [g update];
    }
}

- (void)handleMouseTouch:(float)x And:(float)y
{
    const vector_float3& eye = _camera.get_position();
    
    rcbVector3D     eye_position(eye[0], eye[1], eye[2]);
    
    rcbUnitVector3D eye_direction(0.0, 0.0, 1.0);
    rcbUnitVector3D up_direction(0.0, 1.0, 0.0);
    rcbVector3D     screen_origin(eye_position.getX(),
                                  eye_position.getY(),
                                  eye_position.getZ() + DISTANCE_TO_PROJ_SCREEN
                                  );
    
    rcbPlaneForScreen plane(eye_direction,
                            up_direction,
                            screen_origin
                            );
    
    auto proj00 = _projectionMatrix.columns[0].x;
    auto proj11 = _projectionMatrix.columns[1].y;
    auto scaleX = 1 / proj00;
    auto scaleY = 1 / proj11;
    
    rcbVector3D vc_world = plane.screenToWorld(x * scaleX, y * scaleY);
    
    rcbUnitVector3D ray_direction = vc_world - eye_position;
    
    for (NSUInteger i=0; i<[_geometriesArray count]; ++i)
    {
        metalCustomGeometry* g = [_geometriesArray objectAtIndex:i];
        
        BOOL is_good = [g touchedWithRayOrigin:eye_position
                                  andDirection:ray_direction];
        
        if (is_good)
            NSLog(@"Intersection: %lui",
                  (unsigned long)i
                  );
    }
    
}


- (void)update
{
    metalCustomGeometry* touched = nil;
    
    for (metalCustomGeometry* g in _geometriesArray)
    {
//        if ([g touchedWithRay:{0.f, 0.f, 1.f}])
//            touched = g;
    }
    
    [touched.spacePosition rotateWithAxis:(vector_float3){0.f, 1.0f, 0.f}
                                 andAngle: (int(_rotation) & 1) ? 0.012 : -0.012];
    [touched update];
    
    _rotation += 0.01f;
    
}

- (bool)getNextGeometry:(id<metalGeometryProviderProtocol>*)geometry
             andTexture:(id<metalTextureProviderProtocol>*)texture
{
    assert([_geometriesArray count] == [_texturesArray count]);
    
    if (_nextGeometryIndex >= [_geometriesArray count])
    {
        _nextGeometryIndex = 0;
        
        return NO;
    }
    
    *geometry = [_geometriesArray objectAtIndex:_nextGeometryIndex];
    *texture  = [_texturesArray objectAtIndex:_nextGeometryIndex];
    
    ++_nextGeometryIndex;
    
    return YES;
}

+ (std::vector<simd::float4>)collectPositionsFrom:(id<metalGeometryProviderProtocol>)provider
{
    std::vector<simd::float4> purePositions;
    purePositions.reserve(provider.vertexCount);
    
    simd::float4* v = (simd::float4*) [provider.vertexBuffer contents];
    
    for (auto i=0; i < 2 * provider.vertexCount; i += 2)
    {
        purePositions.push_back(v[i]);
    }
    
    return purePositions;
}

@end
