//
//  Renderer.h
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <MetalKit/MetalKit.h>
#import "metalGeometryProviderProtocol.h"
#import "metalTextureProviderProtocol.h"
//#import "metalViewProjectionProtocol.h"

@interface Renderer : NSObject

- (instancetype)initWithView:(MTKView*)view;

- (void)initPipelineState:(MTLVertexDescriptor*)vertDesc;

- (id<MTLDevice>)getDevice;

- (void)startFrame;

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
           uniformBuffer:(id<MTLBuffer>)uniformBuffer;

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider;

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
                 texture:(id<metalTextureProviderProtocol>)textureProvider
           uniformBuffer:(id<MTLBuffer>)uniformBuffer;

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
                 texture:(id<metalTextureProviderProtocol>)textureProvider;

- (void)endFrame;


@end
