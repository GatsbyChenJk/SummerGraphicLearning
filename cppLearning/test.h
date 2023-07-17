#pragma once
#include <memory>
#include <iostream>

class TestClass
{
private:
	std::unique_ptr<int> testData;
public:
	TestClass()
	{
		testData = nullptr;
	}

	TestClass(int data)
	{
		testData = std::make_unique<int>(data);
		std::cout << data << " has been created!" << std::endl;
	}
	~TestClass()
	{
		std::cout << "Destructor called" << std::endl;
	}
};