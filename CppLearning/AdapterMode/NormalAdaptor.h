#pragma once
#include <iostream>
#include <string>

class RadiusAngles
{
private:
	std::string m_RadAngles = "PI/3";

public :
	virtual ~RadiusAngles() = default;
	virtual std::string ShowAngles() const
	{
		return "[Angles] :" + m_RadAngles + "\trad";
	}
};

class DegreeAngles
{
private:
	std::string m_DegAngles = "60";

public:
	std::string ShowAnglesInDeg()
	{
		return "[Angles] : " + m_DegAngles + "\tdeg";
	}
};

class Adapter : public RadiusAngles
{
private :
	DegreeAngles* _DegAngles;

public:
	Adapter(DegreeAngles* degAngles) : _DegAngles(degAngles){}

	std::string ShowAnglesInRadius()
	{
	    return "[Angles(Deg to rad)] : PI/3\trad";
	}
};

void PlatformShowAngle(const RadiusAngles* angle)
{
	std::cout << angle->ShowAngles()<<"\n";
}