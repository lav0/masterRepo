//
//  mainViewOSX.m
//  masterOfPuppets
//
//  Created by Andrey on 05.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "mainViewOSX.h"

@implementation mainViewOSX

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device
{
    self = [super initWithFrame:frameRect device:device];
    
    return self;
}

@synthesize touchHandler = _touchHandler;

- (void)setTouchHander:(id<touchHandlerProtocol>)touchHandler
{
    _touchHandler = touchHandler;
}


- (void)mouseUp:(NSEvent *)theEvent
{
    CGFloat wdev2  = self.bounds.size.width / 2;
    CGFloat hdev2 = self.bounds.size.height / 2;

    NSPoint point = [theEvent locationInWindow];
  //  NSLog(@"location in window: %f, %f", point.x, point.y);

    float x = (point.x - wdev2) / wdev2;
    float y = (point.y - hdev2) / hdev2;

    [_touchHandler handleMouseTouch:x And:y];
}

@end
