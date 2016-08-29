//
//  textureHolderView.h
//  masterOfPuppets
//
//  Created by Andrey on 27.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "imageProviderProtocol.h"

@interface textureHolderView : THEVIEW<imageProviderProtocol>

+ (float)selfApperanceRate;
- (void)addImage:(THEIMAGE*)image;
- (void)arrangeImages;

@end
