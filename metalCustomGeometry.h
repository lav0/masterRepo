//
//  metalCustomGeometry.h
//  masterOfPuppets
//
//  Created by Andrey on 12.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//
#pragma once

#import "SharedStructures.h"
#import "metalGeometryProviderProtocol.h"

#include "spacePosition3D.hpp"
#include "external/rcbUnitVector3D.h"


@interface metalCustomGeometry : NSObject<metalGeometryProviderProtocol>

@property (assign, nonatomic, readonly) size_t vertexCount;
@property (assign, nonatomic, readonly) size_t indexCount;

- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (instancetype)initWithDevice:(id<MTLDevice>)device andLoadFrom:(NSURL*)source;

- (spacePosition3D)spacePosition3D;
- (void)setSpacePosition3D:(const spacePosition3D&)position;

- (void)update;
- (void)setViewProjection:(matrix_float4x4*)viewProjection;

// result - point on the local (model) coordinate system.
- (BOOL)touchedWithRayOrigin:(const rcbVector3D&)ray_origin
                andDirection:(const rcbUnitVector3D&)direction
                   touchedAt:(vector_float4&)result;

- (Vertex*)getClosestToAim4D:(const simd::float4&)aim;
- (Vertex*)getClosestToAim3D:(const simd::float3&)aim;

@end

