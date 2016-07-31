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
#include <cassert>
#include "SharedStructures.h"

#include "external/rcbPlane.h"

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
    
private:
    Vertex* p_v0;
    Vertex* p_v1;
    Vertex* p_v2;
    
    matrix_float4x4* m_pModel_transformation = nullptr;
};

class linkedGeometry
{
public:
    
    linkedGeometry(Vertex* p_ver_first, size_t v_count,
                   IndexType* p_ind_first, size_t i_count
                   );
    
    void updateModelTransformation(matrix_float4x4* trs);
    
    Vertex* getClosestTo(const simd::float4& aim) const;
    
    bool isIntersectedWithRay(const rcbVector3D&     ray_origin,
                              const rcbUnitVector3D& ray_direction) const;
    
private:
    
    void formFaces();    
    
private:
    
    std::vector<Vertex*>    m_pVertices;
    std::vector<IndexType*> m_pIndices;
    
    std::vector<linkedTriangle> m_faces;
    
    matrix_float4x4*        m_pModel_transformation = nullptr;
    
};

#endif /* pureGeometry_hpp */
