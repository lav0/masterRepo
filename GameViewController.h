//
//  GameViewController.h
//  masterOfPuppets
//
//  Created by Andrey on 20.05.16.
//  Copyright (c) 2016 Andrey. All rights reserved.
//

//#import <Cocoa/Cocoa.h>


#import <MetalKit/MTKView.h>


#if TARGET_IOS==1
typedef UIViewController VIEWCONTROLLER;
#else
typedef NSViewController VIEWCONTROLLER;
#endif

@interface GameViewController : VIEWCONTROLLER<MTKViewDelegate>


@end