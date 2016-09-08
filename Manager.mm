//
//  Manager.m
//  masterOfPuppets
//
//  Created by Andrey on 20.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "Manager.h"
#import "metalGPBlueBox.h"
#import "EntitiesFactory.h"

#include "Camera.hpp"
#include "customGeometryWrapper.h"
#include "convertFunctionsRcb.h"
#include "external/rcbPlaneForScreen.h"
#include "external/rcbSphere.h"

#include <vector>
#include <memory>

static const float DISTANCE_TO_PROJ_SCREEN = 1.f;
static const float VIEW_ANGLE_RAD = 65.0f * (M_PI / 180.0f);


@implementation Manager
{
    id<MTLDevice>             _device;
    id<imageProviderProtocol> _imageProvider;
    
    NSMutableArray* _theModels;
    
    Camera          _camera;
    
    matrix_float4x4 _projectionMatrix;
    
    float           _rotation;
    unsigned int    _nextGeometryIndex;
    
    NSMutableArray* _touchedItems;
    
    bool                _catchTexturePoint;
    metalCustomTexture* _lastCaughtTexture;
    
    ///
    std::unique_ptr<CustomGeometry> geom_cpp;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
              andImageProvider:(id<imageProviderProtocol>)imageProvider
{
    if (self = [super init])
    {
        _device = device;
        _imageProvider = imageProvider;
        
        _theModels       = [[NSMutableArray alloc] init];
        _touchedItems    = [[NSMutableArray alloc] init];
        
        _camera.move( {0.f, 0.f, -8.f} );
        
        _rotation = 0.f;
        _nextGeometryIndex = 0;
        _catchTexturePoint = YES;
        _lastCaughtTexture = nil;
        
        [self createGeometry:device];
        //[self createTexture:device];
    }
    
    return self;
}

- (void)createGeometry:(id<MTLDevice>)device
{
    EntitiesFactoryWrapper factory_wrapper;
    factory_wrapper.factory = [[EntitiesFactory alloc] initWithDevice:device];
    
    metalCustomGeometry* g1 = [factory_wrapper.factory createGeometry:GeometryUnit::QUADRO];
    metalCustomGeometry* g2 = [factory_wrapper.factory createGeometry:GeometryUnit::GRID];
    
    geom_cpp = std::unique_ptr<CustomGeometry>(new CustomGeometry(factory_wrapper));
    
    [g1 setSpacePosition3D:(vector_float3){2.f, 0.f, 0.f}];
    [g2 setSpacePosition3D:(vector_float3){-2.f, 0.f, 0.f}];
    
    [_theModels addObject:[[metalModel alloc] initWithGeometry:g2]];
    [_theModels addObject:[[metalModel alloc] initWithGeometry:g1]];
}

- (void)createTexture:(id<MTLDevice>)device
{
    bool b = YES;
    for (metalModel* m in _theModels)
    {
        auto purePositions = [Manager collectPositionsFrom:[m getGeometry]];
        
        metalCustomTexture* t = [[metalCustomTexture alloc] initWithDevice:device
                                                                  Vertices:purePositions
                                                           andPictureNamed:@"Image008"];
        
        if (b)
        {
            simd::float3 point0 = {0.8f, 0.8f, 0.f};
            simd::float3 point1 = {0.0f, 0.0f, 0.f};
            [t setBindPoints:point0 :point1];
            [t transfromTextureWithBindPoints];
            
            b = NO;
        }
        
        [m addTexture:t];
    }
}

- (void)recalculateProjectionWithWidth:(CGFloat)width AndHeight:(CGFloat)height
{
    float aspect = fabs(width / height);
    _projectionMatrix = matrix_from_perspective_fov_aspectLH(VIEW_ANGLE_RAD,
                                                             aspect,
                                                             DISTANCE_TO_PROJ_SCREEN,
                                                             100.0f
                                                             );
    [self _updateViewProjection];
}

- (void)_updateViewProjection
{
    matrix_float4x4 viewProj = matrix_multiply(_projectionMatrix, _camera.get_view_transformation());
    
    for (metalModel* model in _theModels)
    {
        metalCustomGeometry* g = [model getGeometry];
        
        [g setViewProjection:&viewProj];
        [g update];
    }
    
    geom_cpp->setViewProjection(&viewProj);
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
    
    /// temporary 
    {
        NSLog(@"touched with ray");
        vector_float4 v;
        geom_cpp->touchedWithRayOrigin(eye_position, ray_direction, v);
    }
    
    for (metalModel* model in _theModels)
    {
        metalCustomGeometry* g = [model getGeometry];
        
        vector_float4 touched_p;
        
        BOOL is_good = [g touchedWithRayOrigin:eye_position
                                  andDirection:ray_direction
                                     touchedAt:touched_p];
        
        if (is_good)
        {
            output = touched_p;
            return [_theModels indexOfObject:model];
        }
    }
    
    return -1;
}

- (BOOL)catchTextureOnModel:(metalModel*)model atPoint:(const vector_float3&)v
{
    metalCustomTexture* t = [model getNextTexture];
    
    while (nil != t)
    {
        if ([t catchBindPointBy:v])
        {
            NSLog(@"Caught");
            _catchTexturePoint = NO;
            [_touchedItems removeAllObjects];
            [_touchedItems addObject:model];
            
            _lastCaughtTexture = t;
            
            return YES;
        }
        
        t = [model getNextTexture];
    }
    NSLog(@"Missed");
    return NO;
}

- (BOOL)replaceTexture:(metalCustomTexture*)t OnModel:(metalModel*)model atPoint:(const vector_float3&)point
{
    if ([_touchedItems containsObject:model])
    {
        if ([model contains:t])
        {
            NSLog(@"Replacing");
            
            [t changeCaughtBindPointWith:point];
            _catchTexturePoint = YES;
            _lastCaughtTexture = nil;
            
            return YES;
        }
    }
    
    return NO;
}

- (void)determineTextureBindPointFor:(metalModel*)model
                             atPoint:(const vector_float3&)v
                          bindPoint1:(vector_float3&)bind_out1
                          bindPoint2:(vector_float3&)bind_out2
{
    const simd::float3& eye = _camera.get_position();
    const simd::float3& dir = _camera.get_view_direction();
    
    const rcbVector3D& vc_origin = mop::convertFromSimdToRcb(eye);
    const rcbUnitVector3D& vc_ray = mop::convertFromSimdToRcb(dir);
    
    vector_float4 the_point;
    
    metalCustomGeometry* g = model.getGeometry;
    BOOL is_good = [g touchedWithRayOrigin:vc_origin
                              andDirection:vc_ray
                                 touchedAt:the_point];
    
    float distribution = 1.f;
    
    if (is_good)
    {
        float h = simd::distance(eye, the_point.xyz);
        
        distribution = 2 * h * tan(VIEW_ANGLE_RAD / 2);
        NSLog(@"texture scale recalculated: %f", distribution);
    }
    else
    {
        geom_cpp->getClosestToAim3D(eye);
        geom_cpp->vertexCount();
        
        Vertex* closest_vertex = [g getClosestToAim3D:eye];
        float h = simd::distance(eye, closest_vertex->position.xyz);
        distribution = 1.75 * h * tan(VIEW_ANGLE_RAD / 2);
        NSLog(@"recalcuation failed");
    }
    
    vector_float3 step_right = { 0.1f * distribution, 0.f, 0.f };
    vector_float3 step_left = { -0.1f * distribution, 0.f, 0.f };
    
    bind_out1 = v + step_right;
    bind_out2 = v + step_left;
}

- (void)dropTextureOnModel:(metalModel*)model withImage:(THEIMAGE*)image atPoint:(const vector_float3&)v
{
    vector_float3 bind_right, bind_left;
    
    [self determineTextureBindPointFor:model atPoint:v bindPoint1:bind_right bindPoint2:bind_left];
    
    auto purePositions = [Manager collectPositionsFrom:[model getGeometry]];
    
    metalCustomTexture* t = [[metalCustomTexture alloc] initWithDevice:_device
                                                              Vertices:purePositions
                                                            andPicture:image];
    
    [t setBindPoints:bind_right :bind_left];
    [t transfromTextureWithBindPoints];
    
    [model addTexture:t];
}

- (void)handleMouseTouch:(float)x And:(float)y
{
    vector_float4 point;
    
    NSUInteger index = [self getGeometryAndTouchedPoint:x And:y touchedPoint:point];
    
    vector_float3 point3d = point.xyz;
    
    if (index != -1)
    {
        metalModel* model = [_theModels objectAtIndex:index];
        
        NSImage* image = [_imageProvider getActiveImage];
        
        if (nil != image)
        {
            [self dropTextureOnModel:model withImage:image atPoint:point3d];
            
        }
        else
        {
            if (nil == _lastCaughtTexture)
            {
                if ([self catchTextureOnModel:model atPoint:point3d])
                {
                    return;
                }
            }
            else
            {
                [self replaceTexture:_lastCaughtTexture OnModel:model atPoint:point3d];
            }
        }
    }
    
    _lastCaughtTexture = nil;
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
    for (metalModel* model in _touchedItems)
    {
        metalCustomGeometry* touched = [model getGeometry];
        [touched update];
    }
    
    _rotation += 0.05f;
    
    geom_cpp->update();
}

- (metalModel*)getNextModel
{
    if (_nextGeometryIndex >= [_theModels count])
    {
        _nextGeometryIndex = 0;
        
        return nil;
    }
    
    return [_theModels objectAtIndex:_nextGeometryIndex++];
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
