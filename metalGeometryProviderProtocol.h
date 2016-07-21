//
//  metalGeometryProviderProtocol.h
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Metal/Metal.h>

@protocol metalGeometryProviderProtocol <NSObject>

- (id<MTLBuffer>)vertexBuffer;
- (id<MTLBuffer>)indexBuffer;
- (id<MTLBuffer>)uniformBuffer;
- (size_t)vertexCount;
- (size_t)indexCount;

@end
