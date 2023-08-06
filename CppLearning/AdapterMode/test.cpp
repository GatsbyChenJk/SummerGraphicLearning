#include "NormalAdaptor.h"

int main()
{
	std::cout << "The Platform only support Rad Angles" << std::endl;

	RadiusAngles* RAngles = new RadiusAngles;
	PlatformShowAngle(RAngles);

	DegreeAngles* DAngles = new DegreeAngles;
	std::cout << "Platform don't support this format of Angle :"<<DAngles->ShowAnglesInDeg();
	
	std::cout << std::endl;

	Adapter* DegToRadAdapter = new Adapter(DAngles);
	std::cout << "with the angle adapter the platform can show Deg angles in Rad" << std::endl;
	PlatformShowAngle(DegToRadAdapter);

	delete RAngles;
	delete DAngles;
	delete DegToRadAdapter;

	return 0;
}