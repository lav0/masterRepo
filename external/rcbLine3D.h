#pragma once

#include "rcbQuaternion.h"

class rcbLine3D
{
public:
  rcbLine3D(const rcbVector3D& a_vc_point_1, const rcbVector3D& a_vc_point_2);

  const rcbVector3D& get_point_on_line() const;
  const rcbUnitVector3D& get_vector_along() const;
  
  rcbVector3D get_point_by_param(double a_t) const;

private:

  /////////////////////////////////////////////////////////////////////////////
  //  Line defined by parametric equations:
  //     x = x_0 + a*t;
  //     y = y_0 + b*t; 
  //     z = z_0 + c*t;
  //  
  //  where {x_0, y_0, z_0} - any point on the line (m_vc_point_on),
  //        { a, b, c}    - parallel vector along the line (m_vc_paral_vector)
  //
  /////////////////////////////////////////////////////////////////////////////

  rcbVector3D m_vc_point_on;
  rcbUnitVector3D m_uvc_paral_vector;
};
