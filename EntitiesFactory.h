//
//  EntitiesFactory.h
//  masterOfPuppets
//
//  Created by Andrey on 07.09.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Metal/Metal.h>
#import "metalCustomGeometry.h"

enum class GeometryUnit
{
    GRID = 0,
    QUADRO = 1
};

@interface EntitiesFactory : NSObject

-(instancetype)initWithDevice:(id<MTLDevice>)device;

-(metalCustomGeometry*)createGeometry:(GeometryUnit)whatGeometry;

@end

struct EntitiesFactoryWrapper
{
    EntitiesFactory* factory;
};