//
//  customGeometryWrapper.mm
//  masterOfPuppets
//
//  Created by Andrey on 08.09.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "customGeometryWrapper.h"

struct customGeometryWrapper
{
    metalCustomGeometry* wrapped;
};

CustomGeometry::CustomGeometry(EntitiesFactoryWrapper& factory_wrapper, GeometryUnit gu)
: _pImpl(new customGeometryWrapper)
{
    _pImpl->wrapped = [factory_wrapper.factory createGeometry:gu];
}

CustomGeometry::~CustomGeometry()
{
    if (_pImpl)
    {
        // ??
    }
    
    delete _pImpl;
    _pImpl = nullptr;
}

void CustomGeometry::update()
{
    [_pImpl->wrapped update];
}

void CustomGeometry::setViewProjection(matrix_float4x4* viewProjection)
{
    [_pImpl->wrapped setViewProjection:viewProjection];
}

bool CustomGeometry::touchedWithRayOrigin(const rcbVector3D& ray_origin,
                                          const rcbUnitVector3D& direction,
                                          vector_float4& result)
{
    return [_pImpl->wrapped touchedWithRayOrigin:ray_origin andDirection:direction touchedAt:result];
}

Vertex* CustomGeometry::getClosestToAim4D(const simd::float4& aim)
{
    return [_pImpl->wrapped getClosestToAim4D:aim];
}

Vertex* CustomGeometry::getClosestToAim3D(const simd::float3& aim)
{
    return [_pImpl->wrapped getClosestToAim3D:aim];
}

spacePosition3D CustomGeometry::spacePosition3D() const
{
    return [_pImpl->wrapped spacePosition3D];
}

void CustomGeometry::setSpacePosition3D(const class spacePosition3D& position)
{
    [_pImpl->wrapped setSpacePosition3D:position];
}

size_t CustomGeometry::vertexCount() const
{
    return [_pImpl->wrapped vertexCount];
}

size_t CustomGeometry::indexCount() const
{
    return [_pImpl->wrapped indexCount];
}

void* CustomGeometry::getMetalGeometry()
{
    return (__bridge void*)(_pImpl->wrapped);
}

Vertex* CustomGeometry::getBufferContent()
{
    return (Vertex*)[[_pImpl->wrapped vertexBuffer] contents];
}

