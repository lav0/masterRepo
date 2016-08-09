//
//  linkedTriangle.hpp
//  masterOfPuppets
//
//  Created by Andrey on 01.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#ifndef linkedTriangle_hpp
#define linkedTriangle_hpp

#include <stdio.h>
#include <cassert>

#include "SharedStructures.h"
#include "external/rcbPlane.h"


bool isPointInsideTriangle_bySquares(const vector_float4& a,
                                     const vector_float4& b,
                                     const vector_float4& c,
                                     const vector_float3& point
                                     );
bool isPointInsideTriangle_byBarycentre(const vector_float4& a,
                                        const vector_float4& b,
                                        const vector_float4& c,
                                        const vector_float3& point
                                        );

class linkedTriangle
{
public:
    linkedTriangle(Vertex* p0, Vertex* p1, Vertex* p2);
    
    bool getVertexPosition(unsigned index, simd::float4& output) const;
    bool getVertexPositionTransformed(unsigned index, simd::float4& output) const;
    
    void updateModelTransformation(matrix_float4x4* trs);
    
    rcbUnitVector3D normal() const;
    rcbVector3D     getRcbVertex(unsigned index) const;
    rcbPlane        getRcbPlane() const;
    
    bool intersectionWithLine(const rcbLine3D& line, rcbVector3D& output) const;
    
private:
    Vertex* p_v0;
    Vertex* p_v1;
    Vertex* p_v2;
    
    matrix_float4x4* m_pModel_transformation = nullptr;
};

#endif /* linkedTriangle_hpp */
