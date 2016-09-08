//
//  metalGPBlueBox.h
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalGeometryProviderProtocol.h"


@interface metalGPBlueBox : NSObject<metalGeometryProviderProtocol>


- (instancetype)initWithDevice:(id<MTLDevice>)device;

- (MTLVertexDescriptor*)vertexDescriptor;

@end
