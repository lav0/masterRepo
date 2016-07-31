#pragma once

#include <math.h>

bool is_zero_dbl(double a);

class rcbVector3D;

rcbVector3D operator*(const rcbVector3D&, double);
rcbVector3D operator*(double, const rcbVector3D&);
rcbVector3D operator+(const rcbVector3D&, const rcbVector3D&);
rcbVector3D operator-(const rcbVector3D&, const rcbVector3D&);
double operator*(const rcbVector3D&, const rcbVector3D&);
double operator^(const rcbVector3D&, const rcbVector3D&);
bool operator==(const rcbVector3D&, const rcbVector3D&);
bool operator!=(const rcbVector3D&, const rcbVector3D&);
bool operator||(const rcbVector3D&, const rcbVector3D&);


class rcbVector3D
{
public:

  rcbVector3D();
  rcbVector3D(double a_x, double a_y, double a_z);

  rcbVector3D(const rcbVector3D& a_vc);
  rcbVector3D(rcbVector3D&& a_vc_rvalue);

  rcbVector3D& operator=(const rcbVector3D& a_vc);
  rcbVector3D& operator=(rcbVector3D&& a_vc_rvalue);

  virtual ~rcbVector3D() {}

  virtual void normalize();

  virtual bool is_zero_vector() const;

  virtual double norm() const;
  virtual double square_norm() const;
  
  bool is_orthogonal(const rcbVector3D&) const;

  double getX() const { return m_x; }
  double getY() const { return m_y; }
  double getZ() const { return m_z; }

  rcbVector3D inverted() const { return rcbVector3D(-m_x, -m_y, -m_z); }

  rcbVector3D vector_mul(const rcbVector3D&) const;
  
  rcbVector3D& operator+=(const rcbVector3D&);

protected:

  void become(const double& a_x, const double& a_y, const double& a_z);
  void become(double&& a_x, double&& a_y, double&& a_z);

private:

  double m_x, m_y, m_z;
};


