//
//  linkedTriangle.cpp
//  masterOfPuppets
//
//  Created by Andrey on 01.08.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "linkedTriangle.hpp"

bool isPointInsideTriangle_bySquares(const vector_float4& a,
                                     const vector_float4& b,
                                     const vector_float4& c,
                                     const vector_float3& point
                                     )
{
    auto triangleArea = [](float l1, float l2, float l3)
    {
        auto pd2 = (l1 + l2 + l3) / 2;
        
        return sqrtf( (pd2 - l1) * (pd2 - l2) * (pd2 - l3) * pd2 );
    };
    
    vector_float3 va = {a[0], a[1], a[2]};
    vector_float3 vb = {b[0], b[1], b[2]};
    vector_float3 vc = {c[0], c[1], c[2]};
    
    auto ab = vector_length(va - vb); // 1 "sqrt" + 3 "*" + 5 "+"
    auto bc = vector_length(b - c);
    auto ca = vector_length(c - a);
    
    auto ai = vector_length(va - point);
    auto bi = vector_length(vb - point);
    auto ci = vector_length(vc - point);
    
    auto face_area     = triangleArea(ab, bc, ca);
    auto combined_area = triangleArea(ab, ai, bi) +
                         triangleArea(bc, bi, ci) +
                         triangleArea(ca, ci, ai);
    
    return fabs(face_area - combined_area) < 0.01;
}

bool isPointInsideTriangle_byBarycentre(const vector_float4& a,
                                        const vector_float4& b,
                                        const vector_float4& c,
                                        const vector_float3& point
                                        )
{
//    vector_float3 va = {a[0], a[1], a[2]};
//    vector_float3 vb = {b[0], b[1], b[2]};
//    vector_float3 vc = {c[0], c[1], c[2]};
//    
//    matrix_float3x3 mtx_main = {
//        .column[0] =
//    };
//    
//    matrix_float4x4 m = {
//        .columns[0] = { xscale, 0.0f, 0.0f, 0.0f },
//        .columns[1] = { 0.0f, yscale, 0.0f, 0.0f },
//        .columns[2] = { 0.0f, 0.0f, q, 1.0f },
//        .columns[3] = { 0.0f, 0.0f, q * -nearZ, 0.0f }
//    };
    
    return false;
}

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

//======================================================================================
bool linkedTriangle::isIntersectedByLine(const rcbLine3D& line) const
{
    auto plane = getRcbPlane();
    
    rcbVector3D intersection;
    if (!plane.intersection(line, intersection))
    {
        return false;
    }
    
    simd::float4 a, b, c;
    simd::float3 point = { (float)intersection.getX(), (float)intersection.getY(), (float)intersection.getZ() };
    getVertexPositionTransformed(0, a);
    getVertexPositionTransformed(1, b);
    getVertexPositionTransformed(2, c);
    
//    rcbUnitVector3D uvc(1.0, 0.0, 0.0);
//    uvc.projectionOnPlane(rcbVector3D());
//    
    return isPointInsideTriangle_bySquares(a, b, c, point);
}
