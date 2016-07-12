//
//  metalTextureProviderProtocol.h
//  masterOfPuppets
//
//  Created by Andrey on 12.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Metal/Metal.h>

@protocol metalTextureProviderProtocol <NSObject>

- (id<MTLBuffer>)bufferCoords;
- (id<MTLTexture>)dataMipMap;

@end
