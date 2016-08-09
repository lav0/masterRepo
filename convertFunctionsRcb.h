//
//  convertFunctionsRcb.h
//  masterOfPuppets
//
//  Created by Andrey on 09.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#pragma once

#ifndef convertFunctionsRcb_h
#define convertFunctionsRcb_h

#include "external/rcbVector3D.h"
#include <simd/simd.h>

namespace mop {
    
    rcbVector3D convertFromSimdToRcb(const vector_float3& v);
    
    vector_float3 convertFromRcbToSimd(const rcbVector3D& rcb);
    vector_float4 convertFromRcbToSimdPos(const rcbVector3D& rcb);
    vector_float4 convertFromRcbToSimdRot(const rcbVector3D& rcb);
}

#endif /* convertFunctionsRcb_h */
