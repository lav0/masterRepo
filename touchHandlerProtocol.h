//
//  touchHandlerProtocol.h
//  masterOfPops
//
//  Created by Andrey on 05.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol touchHandlerProtocol <NSObject>

- (void)handleMouseTouch:(float)x And:(float)y;
- (void)handleMouseMove:(float)x And:(float)y With:(float)dx And:(float)dy;
- (void)handleZooming:(float)x And:(float)y Magnification:(float)magni;

@end
