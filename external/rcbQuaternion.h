#pragma once

#include "rcbUnitVector3D.h"


class rcbQuaternion;

rcbQuaternion operator*(const rcbQuaternion& a_qt, double a);
rcbQuaternion operator*(double a, const rcbQuaternion& a_qt);
rcbQuaternion operator*(const rcbQuaternion&, const rcbVector3D& a_v);
rcbQuaternion operator*(const rcbQuaternion&, const rcbQuaternion& a_v);
rcbQuaternion operator+(const rcbQuaternion&, const rcbQuaternion& a_v);


struct Rotation 
{
  Rotation(const rcbUnitVector3D& a_axis, double a_angle)
    : m_angle(a_angle), m_axis(a_axis) {}
    
  const double& angle() const { return m_angle; }
  const rcbVector3D& axis() const { return m_axis; }

private:

  double m_angle;
  rcbVector3D m_axis; 
};


class rcbQuaternion {

public:
  
  rcbQuaternion(double a, double i, double j, double k);
  
  rcbQuaternion(double a_c, const rcbVector3D& a_axis);

  // constructor via rotation attributes: angle and axis
  rcbQuaternion(const Rotation&);
  
  double scal_part() const;
  
  const rcbVector3D& vect_part() const;
  
  double norm() const;

  rcbQuaternion conjugate() const;
  
  rcbQuaternion backward() const;
  
  rcbVector3D turn(const rcbVector3D& a_vc);
  
private:
  
  double m_c;
  rcbVector3D m_v; 
};