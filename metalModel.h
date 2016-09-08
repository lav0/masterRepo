//
//  metalModel.h
//  masterOfPuppets
//
//  Created by Andrey on 12.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Metal/Metal.h>

#include "customGeometryWrapper.h"
//#import "metalCustomGeometry.h"
#import "metalCustomTexture.h"

const unsigned MAX_TEXTURES_PER_GEOMETRY = 3;

@interface metalModel : NSObject

//- (instancetype)initWithGeometry:(metalCustomGeometry*)g;
- (instancetype)initWithGeometry:(CustomGeometry*)g;

- (BOOL)addTexture:(metalCustomTexture*)t;
- (BOOL)contains:(metalCustomTexture*)t;

- (CustomGeometry*)getGeometry;
- (id<metalTextureProviderProtocol>)getNextTexture;

@end
