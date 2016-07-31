#pragma once

#include "rcbPlane.h"

class rcbPlaneForScreen : public rcbPlane
{
public:

  rcbPlaneForScreen(
    const rcbUnitVector3D& a_uvc_norm, 
    const rcbUnitVector3D& a_uvc_up_direction,
    const rcbVector3D&     a_vc_screen_origin
  );

  rcbVector3D screenToWorld(
    double a_screen_x, 
    double a_screen_y
  ) const;

private:

  //
  // Up direction is along Y ort in the screen workplane
  //
  rcbUnitVector3D m_uvc_up_direction;
  rcbVector3D     m_vc_screen_origin;

};