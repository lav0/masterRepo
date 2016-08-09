//
//  mainViewOSX.m
//  masterOfPuppets
//
//  Created by Andrey on 05.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "mainViewOSX.h"

@implementation mainViewOSX
{
    bool _dragStarted;
    
    NSPoint _dragStartPoint;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    [self afterInit];
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    [self afterInit];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device
{
    self = [super initWithFrame:frameRect device:device];
    
    [self afterInit];
    
    return self;
}

- (void)afterInit
{
    _dragStarted = NO;
}

@synthesize touchHandler = _touchHandler;

- (void)setTouchHandler:(id<touchHandlerProtocol>)touchHandler
{
    _touchHandler = touchHandler;
}

- (NSPoint)convertPointToCentral:(NSPoint)input
{
    CGFloat wdev2  = self.bounds.size.width / 2;
    CGFloat hdev2 = self.bounds.size.height / 2;
    
    NSPoint point;
    
    point.x = (input.x - wdev2) / wdev2;
    point.y = (input.y - hdev2) / hdev2;
    
    return point;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    _dragStartPoint = [self convertPointToCentral:[theEvent locationInWindow]];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    _dragStarted = YES;
    
    NSPoint current = [self convertPointToCentral:[theEvent locationInWindow]];
    
    [_touchHandler handleMouseMove:_dragStartPoint.x
                               And:_dragStartPoint.y
                              With:current.x
                               And:current.y
     ];
    
    _dragStartPoint = current;
}

- (void)mouseUp:(NSEvent*)theEvent
{
    if (_dragStarted) {
        _dragStarted = NO;
        return;
    }
    
    NSPoint point = [self convertPointToCentral:[theEvent locationInWindow]];
    
    [_touchHandler handleMouseTouch:point.x And:point.y];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    NSPoint point = [self convertPointToCentral:[event locationInWindow]];
    
    [_touchHandler handleZooming:point.x And:point.y Magnification:event.magnification];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    
}

@end
