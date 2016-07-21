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
#include "SharedStructures.h"

class linkedGeometry
{
public:
    
    linkedGeometry(Vertex* p_ver_first, size_t v_count,
                   IndexType* p_ind_first, size_t i_count
                   );
    
    Vertex* getClosestTo(const simd::float4& aim) const;
    
private:
    
    std::vector<Vertex*>    m_pVertices;
    std::vector<IndexType*> m_pIndices;
    
};

#endif /* pureGeometry_hpp */
