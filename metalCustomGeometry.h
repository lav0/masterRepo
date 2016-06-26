//
//  metalCustomGeometry.h
//  masterOfPuppets
//
//  Created by Andrey on 12.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalGeometryProviderProtocol.h"
#import "metal3DPosition.h"

@interface metalCustomGeometry : NSObject<metalGeometryProviderProtocol>

@property (strong, nonatomic) metal3DPosition *spacePosition;

- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (instancetype)initWithDevice:(id<MTLDevice>)device andLoadFrom:(NSURL*)source;

- (void)setViewProjection:(matrix_float4x4*)viewProjection;

@end
