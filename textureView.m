//
//  textureView.m
//  masterOfPuppets
//
//  Created by Andrey on 28.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "textureView.h"

@implementation textureView

@synthesize isPicked = _isPicked;

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    _isPicked = NO;
    
    return self;
}

- (void)setIsPicked:(bool)value
{
    _isPicked = value;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[self superview] mouseUp:theEvent];
    
    _isPicked = !_isPicked;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (_isPicked)
    {
        [NSBezierPath setDefaultLineWidth:4.0];
        [[NSColor highlightColor] set];
        [NSBezierPath strokeRect:dirtyRect];
    }
}

@end
