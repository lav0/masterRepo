//
//  customGeometryWrapper.h
//  masterOfPuppets
//
//  Created by Andrey on 07.09.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#ifndef customGeometryWrapper_h
#define customGeometryWrapper_h


#import "EntitiesFactory.h"

struct customGeometryWrapper;

class CustomGeometry
{
public:
    
    CustomGeometry(EntitiesFactoryWrapper& factory_wrapper, GeometryUnit gu);
    virtual ~CustomGeometry();
    
    void update();
    
    void setViewProjection(matrix_float4x4* viewProjection);
    
    bool touchedWithRayOrigin(const rcbVector3D& ray_origin,
                              const rcbUnitVector3D& direction,
                              vector_float4& result);
    
    Vertex* getClosestToAim4D(const simd::float4& aim);
    Vertex* getClosestToAim3D(const simd::float3& aim);
    
    spacePosition3D spacePosition3D() const;
    void setSpacePosition3D(const class spacePosition3D& position);
    
    size_t vertexCount() const;
    size_t indexCount() const;
    
    void* getMetalGeometry();
    Vertex* getBufferContent();
    
private:
    
    customGeometryWrapper* _pImpl;
};

#endif /* customGeometryWrapper_h */
