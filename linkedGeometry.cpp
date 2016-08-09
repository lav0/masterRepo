//
//  pureGeometry.cpp
//  masterOfPuppets
//
//  Created by Andrey on 21.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "linkedGeometry.hpp"

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
bool linkedGeometry::intersectionWithRay(const rcbVector3D&     ray_origin,
                                         const rcbUnitVector3D& ray_direction,
                                         rcbVector3D*    output_intersection,
                                         linkedTriangle* output_triangle) const
{
    assert(!m_faces.empty());
    
    rcbLine3D ray_line(ray_origin, ray_origin + ray_direction);
        
    for (auto face : m_faces)
    {
        rcbVector3D vc_intersection;
        if (face.intersectionWithLine(ray_line, vc_intersection))
        {
            if (nullptr != output_intersection)
                *output_intersection = vc_intersection;
            
            if (nullptr != output_triangle)
                *output_triangle = face;
            
            return true;
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