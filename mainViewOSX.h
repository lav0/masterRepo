//
//  mainViewOSX.h
//  masterOfPuppets
//
//  Created by Andrey on 05.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <MetalKit/MetalKit.h>
#import "touchHandlerProtocol.h"

@interface mainViewOSX : MTKView

@property (assign, nonatomic) id<touchHandlerProtocol> touchHandler;

@end
