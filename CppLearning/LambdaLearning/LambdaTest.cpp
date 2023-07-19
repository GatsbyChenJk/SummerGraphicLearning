#include <iostream>
#include <vector>
#include <functional>

void AddByUsingLambda(int& num,const std::function<void(int&)>& func)
{
	func(num);
}

int main()
{
	
	int testArray[] = {1, 6, 5, 9, 8, 4};

	auto testLambda = [](int& num) { num += num * 2; };

	for (int& element : testArray)
	{
		AddByUsingLambda(element, testLambda);
	}

	std::cout << "elements in testArray are :" << std::endl;

	for (int element : testArray)
	{
		std::cout << element << std::endl;
	}
	
	return 0;
}