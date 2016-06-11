//
//  metalGeometry.h
//  masterOfPuppets
//
//  Created by Andrey on 21.05.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Metal/Metal.h>

@interface metalGeometry : NSObject

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer;
@property (nonatomic)         size_t*       indexCount;

@end
