//
//  convertFunctionsRcb.cpp
//  masterOfPuppets
//
//  Created by Andrey on 09.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "convertFunctionsRcb.h"
#include <stdio.h>


namespace mop {
    
    rcbVector3D convertFromSimdToRcb(const vector_float3& v)
    {
        return rcbVector3D(v[0], v[1], v[2]);
    }
    
    vector_float3 convertFromRcbToSimd(const rcbVector3D& rcb)
    {
        return { (float)rcb.getX(), (float)rcb.getY(), (float)rcb.getZ() };
    }
    
    vector_float4 convertFromRcbToSimdPos(const rcbVector3D& rcb)
    {
        return { (float)rcb.getX(), (float)rcb.getY(), (float)rcb.getZ(), 1.f };
    }
    
    vector_float4 convertFromRcbToSimdRot(const rcbVector3D& rcb)
    {
        return { (float)rcb.getX(), (float)rcb.getY(), (float)rcb.getZ(), 0.f };
    }
}