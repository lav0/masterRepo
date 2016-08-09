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
#include "convertFunctionsRcb.h"
#include "external/rcbPlaneForScreen.h"
#include "external/rcbSphere.h"

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
    
    NSMutableArray* _touchedItems;
    
    bool _catchTexturePoint;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        _geometriesArray = [[NSMutableArray alloc] init];
        _texturesArray   = [[NSMutableArray alloc] init];
        _touchedItems    = [[NSMutableArray alloc] init];
        
        _camera.move( {0.f, 0.f, -8.f} );
        
        _rotation = 0.f;
        _nextGeometryIndex = 0;
        _catchTexturePoint = YES;
        
        [self createGeometry:device];
        [self createTexture:device];
    }
    
    return self;
}

- (void)createGeometry:(id<MTLDevice>)device
{
    metal3DPosition* position1 = [[metal3DPosition alloc] initAtPoint:(vector_float3){2.f, 0.f, 0.f}];
    metal3DPosition* position2 = [[metal3DPosition alloc] initAtPoint:(vector_float3){-2.f, 0.f, 0.f}];
    
    NSURL *quadroURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
    NSURL *gridURL = [[NSBundle mainBundle] URLForResource:@"sgrid" withExtension:@"obj"];
    if (quadroURL == nil || gridURL == nil)
        NSLog(@"Sorry. File not found");
    
    metalCustomGeometry* g1 = [[metalCustomGeometry alloc] initWithDevice:device andLoadFrom:quadroURL];
    metalCustomGeometry* g2 = [[metalCustomGeometry alloc] initWithDevice:device]; // andLoadFrom:gridURL];
    
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

- (rcbVector3D)converToScreenPoint:(float)x And:(float)y
{
    const vector_float3& eye = _camera.get_position();
    const vector_float3& dir = _camera.get_view_direction();
    const vector_float3& up  = _camera.get_up_direction();
    
    rcbVector3D     eye_position(mop::convertFromSimdToRcb(eye));
    
    rcbUnitVector3D eye_direction(mop::convertFromSimdToRcb(dir));
    rcbUnitVector3D up_direction(mop::convertFromSimdToRcb(up));
    rcbVector3D     screen_origin(eye_position + DISTANCE_TO_PROJ_SCREEN * eye_direction);
    
    rcbPlaneForScreen plane(eye_direction,
                            up_direction,
                            screen_origin
                            );
    
    auto proj00 = _projectionMatrix.columns[0].x;
    auto proj11 = _projectionMatrix.columns[1].y;
    auto scaleX = 1 / proj00;
    auto scaleY = 1 / proj11;
    
    return plane.screenToWorld(x * scaleX, y * scaleY);
}

- (NSUInteger)getGeometryAndTouchedPoint:(float)x And:(float)y touchedPoint:(vector_float4&)output
{
    const vector_float3& eye = _camera.get_position();
    rcbVector3D eye_position(mop::convertFromSimdToRcb(eye));
    
    rcbVector3D vc_world = [self converToScreenPoint:x And:y];
    rcbUnitVector3D ray_direction = vc_world - eye_position;
    
    for (metalCustomGeometry* g in _geometriesArray)
    {
        vector_float4 touched_p;
        
        BOOL is_good = [g touchedWithRayOrigin:eye_position
                                  andDirection:ray_direction
                                     touchedAt:touched_p];
        
        if (is_good)
        {
            output = touched_p;
            return [_geometriesArray indexOfObject:g];
        }
    }
    
    return -1;
}

- (void)handleMouseTouch:(float)x And:(float)y
{
    vector_float4 v;
    
    NSUInteger index = [self getGeometryAndTouchedPoint:x And:y touchedPoint:v];
    
    if (index != -1)
    {
        metalCustomGeometry* g = [_geometriesArray objectAtIndex:index];
        metalCustomTexture* t = [_texturesArray objectAtIndex:index];
        if (_catchTexturePoint)
        {
            NSLog(@"Catching");
            if ([t catchBindPointBy:v])
            {
                _catchTexturePoint = NO;
                [_touchedItems removeAllObjects];
                [_touchedItems addObject:g];
            }
        }
        else
        {
            NSLog(@"Replacing");
            if ([_touchedItems containsObject:g])
            {
                [t changeCaughtBindPointWith:v];
                _catchTexturePoint = YES;
            }
            
        }
        
    }
}

- (void)handleMouseMove:(float)x And:(float)y With:(float)x2 And:(float)y2
{
    const vector_float3& eye = _camera.get_position();
    rcbVector3D eye_position(mop::convertFromSimdToRcb(eye));
    
    rcbVector3D vc_world1 = [self converToScreenPoint:x And:y];
    rcbVector3D vc_world2 = [self converToScreenPoint:x2 And:y2];
    
    rcbSphere s(rcbVector3D(0.0, 0.0, 0.0), 2.2);
    rcbLine3D line1(eye_position, vc_world1);
    rcbLine3D line2(eye_position, vc_world2);
    
    bool both = YES;
    both &= s.intersection(line1, vc_world1);
    both &= s.intersection(line2, vc_world2);
    
    if (both)
    {
        auto axis = vc_world2.vector_mul(vc_world1);
        if (!axis.is_zero_vector())
            axis.normalize();
        
        auto angle = (float) (vc_world2 ^ vc_world1);
        
        _camera.rotate(mop::convertFromRcbToSimd(axis), angle);
        [self _updateViewProjection];
    }
}

- (void)handleZooming:(float)x And:(float)y Magnification:(float)magni
{
    rcbVector3D vc_world = [self converToScreenPoint:x And:y];
    
    const vector_float3& eye = _camera.get_position();
    rcbVector3D eye_position(mop::convertFromSimdToRcb(eye));
    
    rcbUnitVector3D zoom_direction = vc_world - eye_position;
    
    rcbVector3D magnification = 2 * magni * zoom_direction;
    
    _camera.move(mop::convertFromRcbToSimd(magnification));
    [self _updateViewProjection];
}


- (void)update
{
    for (metalCustomGeometry* touched in _touchedItems)
    {
        [touched update];
    }
    
    _rotation += 0.05f;
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
