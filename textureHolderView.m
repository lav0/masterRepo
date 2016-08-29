//
//  textureHolderView.m
//  masterOfPuppets
//
//  Created by Andrey on 27.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "textureHolderView.h"
#import "textureView.h"


@implementation textureHolderView
{
    NSMutableArray* _imageViews;
}

+ (float)selfApperanceRate { return 0.2; }

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self)
    {
        _imageViews = [[NSMutableArray alloc] init];
        
        THEIMAGE *image = [THEIMAGE imageNamed:@"rounds"];
        
        if (image == nil)
            NSLog(@"round image not found");
        
        [self addImage:image];
        [self addImage:[THEIMAGE imageNamed:@"Image008"]];
        [self addImage:[THEIMAGE imageNamed:@"rounds"]];
    }
    
    return self;
}

- (void)addImage:(THEIMAGE*)image
{
    if (nil == image)
        return;
    
    CGRect small_rect = CGRectMake(30, 30, 50, 250);
    textureView* image_view = [[textureView alloc] initWithFrame:small_rect];
    
    [image_view setImage:image];
    [self addSubview:image_view];
    
    [_imageViews addObject:image_view];
}

- (void)arrangeImages
{
    CGRect host = [self frame];
    
    CGFloat w = host.size.width;
    CGFloat h = host.size.height;
    CGFloat ww = 0.6 * w;
    
    unsigned long n = [_imageViews count];
    
    for (unsigned i=0; i < n; ++i)
    {
        NSImageView* iv = [_imageViews objectAtIndex:i];
        
        float xc = w / 2;
        float yc = (i+1) * h / (n+1);
        
        float shift = ww / 2;
        
        [iv setFrameOrigin:CGPointMake(xc - shift, yc - shift)];
        [iv setFrameSize:CGSizeMake(ww, ww)];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    for (textureView* v in _imageViews)
    {
        [v setIsPicked:NO];
        [v setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSColor* bc = [NSColor colorWithCalibratedRed:0.227f
                                            green:0.251f
                                             blue:0.337
                                            alpha:0.8];
    
    [bc setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (THEIMAGE*)getActiveImage
{
    for (textureView* v in _imageViews)
    {
        if (v.isPicked)
            return [v image];
    }
    
    return nil;
}

@end
