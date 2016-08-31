//
//  pureGeometry.hpp
//  masterOfPuppets
//
//  Created by Andrey on 21.07.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#ifndef pureGeometry_hpp
#define pureGeometry_hpp

#include <stdio.h>
#include <vector>
#include "linkedTriangle.hpp"

class linkedGeometry
{
public:
    
    linkedGeometry(Vertex* p_ver_first, size_t v_count,
                   IndexType* p_ind_first, size_t i_count
                   );
    
    void updateModelTransformation(matrix_float4x4* trs);
    
    Vertex* getClosestTo(const simd::float4& aim) const;
    Vertex* getClosestTo(const simd::float3& aim) const;
    
    bool intersectionWithRay(const rcbVector3D&     ray_origin,
                             const rcbUnitVector3D& ray_direction,
                             rcbVector3D*    output_intersection = nullptr,
                             linkedTriangle* output_triangle = nullptr) const;
    
private:
    
    void formFaces();    
    
private:
    
    std::vector<Vertex*>    m_pVertices;
    std::vector<IndexType*> m_pIndices;
    
    std::vector<linkedTriangle> m_faces;
    
    matrix_float4x4*        m_pModel_transformation = nullptr;
    
};

#endif /* pureGeometry_hpp */
