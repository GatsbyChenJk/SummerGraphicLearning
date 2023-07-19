#include "Single.h"

int main()
{
	Single* testInstance = Single::GetInstance(1);
	
	testInstance->BussinessLogic();

	Single* testInstance2 = Single::GetInstance(5);
	
	testInstance2->BussinessLogic();
}