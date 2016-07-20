//
//  GameViewController.m
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright (c) 2016 Andrey. All rights reserved.
//

#import "GameViewController.h"
#import <Metal/Metal.h>
#import <simd/simd.h>

#import "Manager.h"
#import "metalGPBlueBox.h"
#import "metalCustomGeometry.h"
#import "metalCustomTexture.h"
#import "Renderer.h"
#import "metal3DPosition.h"
#import "SharedStructures.h"

#include "Camera.hpp"
#include <vector>


@implementation GameViewController
{
    Renderer* _renderer;
    
    Manager* _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    ((MTKView *)self.view).delegate = self;
    
    _renderer = [[Renderer alloc] initWithView:(MTKView *)self.view];
    
    id<MTLDevice> _device = [_renderer getDevice];
    
    _manager = [[Manager alloc] initWithDevice:_device];
    
    metalGPBlueBox* box = [[metalGPBlueBox alloc] initWithDevice:_device];
    
    [_renderer initPipelineState:[box vertexDescriptor]];
    
    [self _reshape];
}


- (void)_render
{
    [_manager update];

    [_renderer startFrame];
    
    [_renderer drawWithGeometry:_manager.getGeometry0];
    
    [_renderer drawWithGeometry:_manager.getGeometry1 texture:_manager.getTexture];
    
    [_renderer endFrame];
}

- (void)_reshape
{
    [_manager recalculateProjectionWithWidth:self.view.bounds.size.width
                                   AndHeight:self.view.bounds.size.height];
}

// Called whenever view changes orientation or layout is changed
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    [self _reshape];
}


// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view
{
    @autoreleasepool {
        [self _render];
    }
}

@end
