//
//  linkedTriangle.cpp
//  masterOfPuppets
//
//  Created by Andrey on 01.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "linkedTriangle.hpp"


//======================================================================================
//  linkedTriangle
//======================================================================================

//======================================================================================
linkedTriangle::linkedTriangle(Vertex* p0, Vertex* p1, Vertex* p2)
: p_v0(p0), p_v1(p1), p_v2(p2)
{}

//======================================================================================
void linkedTriangle::updateModelTransformation(matrix_float4x4* trs)
{
    m_pModel_transformation = trs;
}

//======================================================================================
bool linkedTriangle::getVertexPosition(unsigned index, simd::float4& output) const
{
    switch (index) {
        case 0:
            output = p_v0->position;
            break;
        case 1:
            output = p_v1->position;
            break;
        case 2:
            output = p_v2->position;
            break;
        default:
            assert(false);
            return false;
    }
    
    return true;
}

//======================================================================================
bool linkedTriangle::getVertexPositionTransformed(unsigned index, simd::float4& output) const
{
    bool good = getVertexPosition(index, output);
    
    if (good && nullptr != m_pModel_transformation)
    {
        output = matrix_multiply(*m_pModel_transformation, output);
    }
    
    return good;
}

//======================================================================================
rcbUnitVector3D linkedTriangle::normal() const
{
    simd::float4 p0, p1, p2;
    
    getVertexPositionTransformed(0, p0);
    getVertexPositionTransformed(1, p1);
    getVertexPositionTransformed(2, p2);
    
    rcbVector3D v0(p0[0], p0[1], p0[2]);
    rcbVector3D v1(p1[0], p1[1], p1[2]);
    rcbVector3D v2(p2[0], p2[1], p2[2]);
    
    return (v1 - v0).vector_mul(v2 - v0);
}

//======================================================================================
rcbVector3D linkedTriangle::getRcbVertex(unsigned index) const
{
    assert(index < 3);
    
    simd::float4 v;
    getVertexPositionTransformed(index % 3, v);
    
    return rcbVector3D(v[0], v[1], v[2]);
}

//======================================================================================
rcbPlane linkedTriangle::getRcbPlane() const
{
    return rcbPlane(normal(), getRcbVertex(0));
}
