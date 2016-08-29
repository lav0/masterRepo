//
//  metalCustomTexture.h
//  masterOfPuppets
//
//  Created by Andrey on 12.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "metalTextureProviderProtocol.h"
#import "imageProviderProtocol.h"
#import <Metal/Metal.h>
#import <simd/simd.h>
#include <vector>

@interface metalCustomTexture : NSObject<metalTextureProviderProtocol>


- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
               andPictureNamed:(NSString*)fileName;

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      Vertices:(std::vector<simd::float4>)vertices
                    andPicture:(THEIMAGE*)image;

- (void)setBindPoints:(simd::float3&)bind1 :(simd::float3&)bind2;
- (void)transfromTextureWithBindPoints;

- (id<MTLBuffer>)bufferCoords;
- (id<MTLTexture>)dataMipMap;

- (bool)catchBindPointBy:(simd::float3)point;
- (bool)changeCaughtBindPointWith:(simd::float3)point;

@end
