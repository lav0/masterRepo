//
//  Camera.cpp
//  masterOfPuppets
//
//  Created by Andrey on 11.06.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#include "Camera.hpp"
#include <iostream>

Camera::Camera()
{
    std::cout << "Camera has been created\n";
}

Camera::Camera(vector_float3& eye, vector_float3& direction, vector_float3& up)
: m_position(eye)
, m_direction(direction)
, m_orientation(up)
{
}

void Camera::move(const vector_float3& shift)
{
    m_position = m_position + shift;

    m_recalculate_view_needed = true;
}

void Camera::rotate(const vector_float3& axis, const float angle)
{
    auto mtx = matrix3x3_from_rotation(angle, axis[0], axis[1], axis[2]);
    
    m_position    = matrix_multiply(mtx, m_position);
    m_direction   = matrix_multiply(mtx, m_direction);
    m_orientation = matrix_multiply(mtx, m_orientation);
    
    m_recalculate_view_needed = true;
}

bool Camera::recalculate_view_transformation()
{
    if (!m_recalculate_view_needed)
        return false;
    
    m_view_transformation = matrix_look_along(m_position, m_direction, m_orientation);
    
    m_recalculate_view_needed = false;
    
    return true;
}

const matrix_float4x4& Camera::get_view_transformation()
{
    recalculate_view_transformation();
    
    return m_view_transformation;
}

const vector_float3& Camera::get_position() const
{
    return m_position;
}

const vector_float3& Camera::get_view_direction() const
{
    return m_direction;
}
const vector_float3& Camera::get_up_direction() const
{
    return m_orientation;
}