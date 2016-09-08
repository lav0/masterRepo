//
//  EntitiesFactory.m
//  masterOfPuppets
//
//  Created by Andrey on 07.09.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "EntitiesFactory.h"

@implementation EntitiesFactory
{
    id<MTLDevice> _device;
}

-(instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self)
    {
        _device = device;
    }
    
    return self;
}

-(metalCustomGeometry*)createGeometry:(GeometryUnit)whatGeometry
{
    NSURL* sourceURL = [[NSBundle mainBundle] URLForResource:@"quadro_grid" withExtension:@"obj"];
    
    switch (whatGeometry) {
        case GeometryUnit::GRID:
            sourceURL = [[NSBundle mainBundle] URLForResource:@"sgrid" withExtension:@"obj"];
            break;
            
        default:
            break;
    }
    
    if (sourceURL == nil)
        NSLog(@"Sorry. File not found");
    
    return [[metalCustomGeometry alloc] initWithDevice:_device andLoadFrom:sourceURL];
}

@end
