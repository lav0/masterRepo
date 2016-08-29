//
//  imageProviderProtocol.h
//  masterOfPuppets
//
//  Created by Andrey on 28.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#if TARGET_IOS==1
typedef UIImage THEIMAGE;
typedef UIView  THEVIEW;
#else
typedef NSImage THEIMAGE;
typedef NSView  THEVIEW;
#endif

@protocol imageProviderProtocol <NSObject>

- (THEIMAGE*)getActiveImage;

@end
