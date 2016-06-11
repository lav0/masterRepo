//
//  metalGPBlueBox.h
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalGeometryProviderProtocol.h"
#import "metal3DPosition.h"

@interface metalGPBlueBox : NSObject<metalGeometryProviderProtocol>

@property (strong, nonatomic) metal3DPosition *spacePosition;

- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (instancetype)initWithDevice:(id<MTLDevice>)device andPosition:(metal3DPosition*)position;
- (MTLVertexDescriptor*)vertexDescriptor;

- (id<MTLBuffer>)vertexBuffer;
- (id<MTLBuffer>)uniformBuffer;
- (id<MTLBuffer>)indexBuffer;
- (size_t)indexCount;

- (void)setViewProjection:(matrix_float4x4*)viewProjection;

@end
