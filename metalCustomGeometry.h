//
//  metalCustomGeometry.h
//  masterOfPuppets
//
//  Created by Andrey on 12.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "SharedStructures.h"
#import "metalGeometryProviderProtocol.h"
#import "metal3DPosition.h"

@interface metalCustomGeometry : NSObject<metalGeometryProviderProtocol>

@property (strong, nonatomic) metal3DPosition *spacePosition;
@property (assign, nonatomic, readonly) size_t vertexCount;
@property (assign, nonatomic, readonly) size_t indexCount;

- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (instancetype)initWithDevice:(id<MTLDevice>)device andLoadFrom:(NSURL*)source;

- (void)update;
- (void)setViewProjection:(matrix_float4x4*)viewProjection;

- (Vertex*)getClosestTo:(const simd::float4&)aim;

@end
