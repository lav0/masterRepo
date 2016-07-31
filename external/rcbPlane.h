#pragma once

#include "rcbLine3D.h"


class rcbPlane
{
public:
  rcbPlane(const rcbUnitVector3D& a_vc_norm, const rcbVector3D& a_vc_point_on);

  bool intersection(const rcbLine3D&, rcbVector3D& a_vc_result) const;

  const rcbUnitVector3D& get_norm() const;
  double get_free_coef() const;

private:

  
  /////////////////////////////////////////////////////////////////////////////
  // Defined by normal equation
  //
  // A*x + B*y + C*z = D,
  // {A, B, C} - m_vc_norm, D - d_free_coef
  /////////////////////////////////////////////////////////////////////////////

  rcbUnitVector3D m_uvc_norm;
  double d_free_coef;
};