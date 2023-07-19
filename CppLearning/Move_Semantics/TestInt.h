#pragma once
#include <iostream>
#include <vector>

class TestInt
{
private:	
	std::vector<int> m_data;
public:
	TestInt()
	{	   
		std::cout << "New Heap Created" << std::endl;
	}
	TestInt(const int& value)
	{
		std::cout << "New Heap Created" << std::endl;
		m_data.push_back(value);
	}
	void Traversal()
	{
		std::cout << "data stored are:" ;
		for (auto& nums : m_data)
		{
			std::cout << nums << " ";
		}
		std::cout << std::endl;
	}
	~TestInt()
	{
		std::cout << "Deleted" << std::endl;
	}
	void ProcessVector(TestInt other)
	{
		m_data.push_back(other.m_data.front());
	}
	
};