//
//  Manager.h
//  masterOfPuppets
//
//  Created by Andrey on 20.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <MetalKit/MTKView.h>

#import "metalGeometryProviderProtocol.h"
#import "metalTextureProviderProtocol.h"

@interface Manager : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device;

- (void)recalculateProjectionWithWidth:(CGFloat)width AndHeight:(CGFloat)height;

- (void)update;

- (id<metalGeometryProviderProtocol>)getGeometry0;
- (id<metalGeometryProviderProtocol>)getGeometry1;
- (id<metalTextureProviderProtocol>)getTexture0;
- (id<metalTextureProviderProtocol>)getTexture1;

@end
