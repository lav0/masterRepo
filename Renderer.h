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

- (void)drawWithGeometry:(id<metalGeometryProviderProtocol>)geometryProvider;
- (void)setTexture:(id<metalTextureProviderProtocol>)textureProvider;

- (void)endFrame;


@end
