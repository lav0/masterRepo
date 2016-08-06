#pragma once

#include "rcbPlane.h"

class rcbSphere
{
public:
  rcbSphere(const rcbVector3D& a_vc, double a_rad);

  bool intersection(
    const rcbLine3D& a_line, 
    rcbVector3D& a_vc_out1, 
    rcbVector3D& a_vc_out2
  ) const;
  
  bool intersection(
    const rcbLine3D& a_line, 
    rcbVector3D& a_vc_out
  ) const;

private:

  rcbVector3D m_centre;
  double      m_radius;
};