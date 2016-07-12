//
//  metalCustomTexture.h
//  masterOfPuppets
//
//  Created by Andrey on 12.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalTextureProviderProtocol.h"
#import <Metal/Metal.h>
#import <simd/simd.h>
#include <vector>

@interface metalCustomTexture : NSObject<metalTextureProviderProtocol>

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
                    andPicture:(NSString*)fileName;

- (id<MTLBuffer>)bufferCoords;
- (id<MTLTexture>)dataMipMap;

@end
