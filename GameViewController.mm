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

#import "Renderer.h"
#import "Manager.h"
#import "metalGPBlueBox.h"

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
    
    mainViewIOS* main_view = (mainViewIOS*)self.view;

    main_view.delegate = self;
    
    _renderer = [[Renderer alloc] initWithView:main_view];
    
    id<MTLDevice> _device = [_renderer getDevice];
    
    _manager = [[Manager alloc] initWithDevice:_device];
    main_view.touchHander = _manager;
    
    metalGPBlueBox* box = [[metalGPBlueBox alloc] initWithDevice:_device];
    
    [_renderer initPipelineState:[box vertexDescriptor]];
    
    [self _reshape];
}

//- (void)mouseUp:(NSEvent *)theEvent
//{
//    CGFloat wdev2  = self.view.bounds.size.width / 2;
//    CGFloat hdev2 = self.view.bounds.size.height / 2;
//    
//    NSPoint point = [theEvent locationInWindow];
//  //  NSLog(@"location in window: %f, %f", point.x, point.y);
//    
//    float x = (point.x - wdev2) / wdev2;
//    float y = (point.y - hdev2) / hdev2;
//    
//    [_manager handleMouseTouch:x And:y];
//}


- (void)_render
{
    [_manager update];

    [_renderer startFrame];
    
    id<metalGeometryProviderProtocol> g;
    id<metalTextureProviderProtocol> t;
    
    while ([_manager getNextGeometry:&g andTexture:&t])
    {
        [_renderer drawWithGeometry:g texture:t];
    }
    
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
