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
#import "textureHolderView.h"

#include "Camera.hpp"

#include <vector>


@implementation GameViewController
{
    MTKView * _root_view;
    MAINVIEW* _world_view;
    textureHolderView* _txt_view;
    
    Renderer* _renderer;
    
    Manager* _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = [self.view frame];
    
    _world_view = [[MAINVIEW alloc] initWithFrame:rect];
    _txt_view   = [[textureHolderView alloc] initWithFrame:rect];
    
    _renderer = [[Renderer alloc] initWithView:_world_view];
    
    id<MTLDevice> _device = [_renderer getDevice];
    
    _manager = [[Manager alloc] initWithDevice:_device andImageProvider:_txt_view];
    _world_view.touchHandler = _manager;
    
    metalGPBlueBox* box = [[metalGPBlueBox alloc] initWithDevice:_device];
    
    [_renderer initPipelineState:[box vertexDescriptor]];
    
    _root_view = (MTKView*)self.view;
    
    [_root_view setDelegate:self];
    [_root_view addSubview:_world_view];
    [_root_view addSubview:_txt_view];
    
    [self _reshape];
}

- (void)_render
{
    [_manager update];

    [_renderer startFrame];
    
    metalModel* curModel = [_manager getNextModel];
    while (nil != curModel)
    {
        id<metalTextureProviderProtocol> t = [curModel getNextTexture];
        
        while (nil != t)
        {
            [_renderer addTexture:t];
            
            t = [curModel getNextTexture];
        }
        
        [_renderer drawWithGeometry:[curModel getGeometry]];
        
        curModel = [_manager getNextModel];
    }
    
    [_renderer endFrame];
}

- (void)_reshape
{
    CGSize newsize = [self.view frame].size;
    
    // world view rate
    CGFloat wvc = 1.0 - [textureHolderView selfApperanceRate];
    CGSize world_size = CGSizeMake(wvc * newsize.width, newsize.height);
    CGSize txt_size   = CGSizeMake((1-wvc) * newsize.width, newsize.height);
    CGPoint txt_point = CGPointMake(world_size.width, 0);
    
    [_world_view setFrameSize:world_size];
    [_txt_view setFrameSize:txt_size];
    [_txt_view setFrameOrigin:txt_point];
    [_txt_view arrangeImages];
    
    [_manager recalculateProjectionWithWidth:_world_view.bounds.size.width
                                   AndHeight:_world_view.bounds.size.height];
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
