//
//  pureGeometry.cpp
//  masterOfPuppets
//
//  Created by Andrey on 21.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "linkedGeometry.hpp"

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
}

//======================================================================================::
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