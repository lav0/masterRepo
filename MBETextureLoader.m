//
//  MBETextureLoader.m
//  InstancedDrawing
//
//  Created by Warren Moore on 11/7/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import "MBETextureLoader.h"
#import <MetalKit/MetalKit.h>

@implementation MBETextureLoader

+ (uint8_t *)dataForImage:(NSImage *)image
{
    NSRect nsrect = NSRectFromCGRect(CGRectMake(0, 0, image.size.width, image.size.height));
    CGImageRef imageRef = [image CGImageForProposedRect:&nsrect
                                                context:nil hints:nil];
    
    // Create a suitable bitmap context for extracting the bits of the image
    const NSUInteger width = CGImageGetWidth(imageRef);
    const NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * width;
    const NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}

+ (id<MTLTexture>)texture2DWithImageNamed:(NSString *)imageName device:(id<MTLDevice>)device
{
    NSImage *image = [NSImage imageNamed:imageName];
    
    if (image == nil)
        NSLog(@"Image not found");
    
    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * imageSize.width;
    uint8_t *imageData = [self dataForImage:image];
    
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                 width:imageSize.width
                                                                                                height:imageSize.height
                                                                                             mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = MTLRegionMake2D(0, 0, imageSize.width, imageSize.height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:imageData bytesPerRow:bytesPerRow];
    
    free(imageData);
    
    return texture;
}

+ (id<MTLTexture>)textureWithImageNamed:(NSString*)imageName device:(id<MTLDevice>)device
{
    NSImage *image = [NSImage imageNamed:imageName];
    NSRect nsrect = NSRectFromCGRect(CGRectMake(0, 0, image.size.width, image.size.height));
    CGImageRef imageRef = [image CGImageForProposedRect:&nsrect context:nil hints:nil];
    
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
    
    return [loader newTextureWithCGImage:imageRef options:nil error:nil];
}

@end
