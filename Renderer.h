//
//  Renderer.h
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <MetalKit/MetalKit.h>
#import "metalGeometryProviderProtocol.h"
//#import "metalViewProjectionProtocol.h"

@interface Renderer : NSObject

- (instancetype)initWithLayer:(CAMetalLayer *)metalLayer;
- (void)initPipelineState:(MTLVertexDescriptor*)vertDesc;

- (id<MTLDevice>)getDevice;

- (void)startFrame:(MTLRenderPassDescriptor*)passDesc;

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider
           uniformBuffer:(id<MTLBuffer>)uniformBuffer;

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider;

- (void)endFrame:(id<CAMetalDrawable>)drawable;

@end
