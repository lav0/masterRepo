//
//  Manager.h
//  masterOfPuppets
//
//  Created by Andrey on 20.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <MetalKit/MTKView.h>

#import "metalModel.h"
#import "touchHandlerProtocol.h"
#import "imageProviderProtocol.h"

@interface Manager : NSObject<touchHandlerProtocol>

- (instancetype)initWithDevice:(id<MTLDevice>)device
              andImageProvider:(id<imageProviderProtocol>)imageProvider;

- (void)recalculateProjectionWithWidth:(CGFloat)width AndHeight:(CGFloat)height;

- (void)update;

- (metalModel*)getNextModel;


@end
