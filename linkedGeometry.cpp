//
//  pureGeometry.cpp
//  masterOfPuppets
//
//  Created by Andrey on 21.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "linkedGeometry.hpp"

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
//  linkedGeometry
//======================================================================================
linkedGeometry::linkedGeometry(Vertex* p_ver_first, size_t v_count,
                               IndexType* p_ind_first, size_t i_count
                               )
{
    size_t i = 0;
    
    m_pVertices.reserve(v_count);
    
    for (i = 0; i < v_count; ++i)
        m_pVertices.push_back(&p_ver_first[i]);
    
    m_pIndices.reserve(i_count);
    
    for (i = 0; i < i_count; ++i)
        m_pIndices.push_back(&p_ind_first[i]);
    
    formFaces();
}

//======================================================================================
void linkedGeometry::formFaces()
{
    assert(m_pIndices.size() % 3 == 0);
    
    m_faces.clear();
    m_faces.reserve(m_pIndices.size());
    
    for (size_t i=0; i<m_pIndices.size(); i = i + 3)
    {
        auto ind0 = *(m_pIndices[i]);
        auto ind1 = *(m_pIndices[i+1]);
        auto ind2 = *(m_pIndices[i+2]);
        
        m_faces.push_back(linkedTriangle(
                                        m_pVertices[ind0],
                                        m_pVertices[ind1],
                                        m_pVertices[ind2]
                                        )
                          );
    }
}

//======================================================================================
void linkedGeometry::updateModelTransformation(matrix_float4x4* trs)
{
    m_pModel_transformation = trs;
    
    std::for_each(m_faces.begin(), m_faces.end(), [&trs](linkedTriangle& face)
                  {
                      face.updateModelTransformation(trs);
                  }
                  );
}

//======================================================================================
bool linkedGeometry::isIntersectedWithRay(const rcbVector3D&     ray_origin,
                                          const rcbUnitVector3D& ray_direction) const
{
    assert(!m_faces.empty());
    
    rcbLine3D ray_line(ray_origin, ray_origin + ray_direction);
    
    auto triangleArea = [](float l1, float l2, float l3)
    {
        auto pd2 = (l1 + l2 + l3) / 2;
        
        return sqrtf( (pd2 - l1) * (pd2 - l2) * (pd2 - l3) * pd2 );
    };
    
    for (auto face : m_faces)
    {
        auto plane = face.getRcbPlane();
        
        rcbVector3D intersection;
        if (plane.intersection(ray_line, intersection))
        {
            //
            // now, let's try to check if intersection is inside the triangle
            //
            
            auto a = face.getRcbVertex(0);
            auto b = face.getRcbVertex(1);
            auto c = face.getRcbVertex(2);
            
            auto ab = (a - b).norm();
            auto bc = (b - c).norm();
            auto ca = (c - a).norm();
            
            auto ai = (a - intersection).norm();
            auto bi = (b - intersection).norm();
            auto ci = (c - intersection).norm();
            
            auto face_area = triangleArea(ab, bc, ca);
            auto combined_area = triangleArea(ab, ai, bi) +
                                 triangleArea(bc, bi, ci) +
                                 triangleArea(ca, ci, ai);
            
            if (fabs(face_area - combined_area) < 0.01)
            {
                return true;
            }
        }
    }
    
    return false;
}

//======================================================================================
Vertex* linkedGeometry::getClosestTo(const simd::float4& aim) const
{
    float min_dist = __FLT_MAX__;
    Vertex* closest = nullptr;
    
    for (auto v : m_pVertices)
    {
        auto d = simd::distance_squared(v->position, aim);
        
        if (min_dist > d)
        {
            min_dist = d;
            closest = v;
        }
    }
    
    return closest;
}