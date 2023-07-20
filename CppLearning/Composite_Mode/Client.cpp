#include "Composite.h"


int main()
{
	Component* singleComp = new SingleComponent;
	ClientCheckCompnonetType(singleComp);
	if (!singleComp->IsComposite())
	{
		std::cout << "Client : create a composite which is single" << std::endl;
	}

	Component* complexComp1 = new ComplexComponent;
	Component* complexComp2 = new ComplexComponent;
	
	complexComp1->Add(complexComp1);
	complexComp2->Add(complexComp2);
	complexComp1->Remove(complexComp1);
	ClientCheckCompnonetType(complexComp2);
	if (complexComp1->IsComposite())
	{
		std::cout << "Client : create a composite which is complex" << std::endl;
	}
	//注意最后释放内存
	delete singleComp;
	delete complexComp1;
	delete complexComp2;
}