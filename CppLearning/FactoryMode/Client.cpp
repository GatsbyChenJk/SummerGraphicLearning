#include "SimpleFactory.h"
#include "AbstractFactory.h"
#include <iostream>

int main()
{
	//简单工厂测试用例
	std::cout << "Client 1: Ordered a LemonTea" << std::endl;
	DrinkFactory* factory = new LemonTeaFactory();
	ClientOrdering(*factory);

	std::cout << std::endl;

	std::cout << "Client 2: Ordered a MilkTea" << std::endl;
	factory = new MilkTeaFactory();
	ClientOrdering(*factory);

	delete factory;

	//抽象工厂测试用例
	std::cout << "User 1 : make a drawing triangle implement" << std::endl;
	Renderer* Renderer = new TriangleRenderer();
	UserOperation(*Renderer);

	std::cout << std::endl;

	std::cout << "User 2 : make a drawing rectangle implement" << std::endl;
	Renderer = new RectangleRenderer();
	UserOperation(*Renderer);

	delete Renderer;
}