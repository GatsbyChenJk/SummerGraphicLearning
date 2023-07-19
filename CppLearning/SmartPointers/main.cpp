#include "test.h"
#include <iostream>

int main()
{
	//栈上分配
	//TestClass DataTest1;
	//堆上分配
	TestClass *DataTest2 = new TestClass(5);
	delete DataTest2;
}