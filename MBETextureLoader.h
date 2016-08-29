//
//  MBETextureLoader.h
//  InstancedDrawing
//
//  Created by Warren Moore on 11/7/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

//#import <AppKit/AppKit.h>

//#import <UIKit/UIKit.h>
#import <Metal/Metal.h>


#if TARGET_IOS==1
typedef UIImage THEIMAGE;
#else
typedef NSImage THEIMAGE;
#endif

@interface MBETextureLoader : NSObject

+ (id<MTLTexture>)texture2DWithImageNamed:(NSString *)imageName device:(id<MTLDevice>)device;
+ (id<MTLTexture>)texture2DWithImage:(THEIMAGE *)image device:(id<MTLDevice>)device;

@end
