#pragma once
#include <iostream>
#include <string>

class InAndOut
{
private:
	int testdata_int;
	std::string testdata_string;
public:
	InAndOut()
	{
		testdata_int = 0;
		testdata_string = "nfjsnfsk";
	}
	InAndOut(const int& value)
	{
		testdata_int = value;
	}
	InAndOut(const std::string& str)
	{
		testdata_string = str;
	}
	InAndOut(const int& value,const std::string& str)
		:InAndOut(value)
	{
		testdata_string = str;
	}

	//how to detect whether a varible is lvalue or rvalue
	void GetValue(int& value)
	{
		std::cout << "[lvalue]" << value << std::endl;
	}

	void GetValue(int&& value)
	{
		std::cout << "[rvalue]" << value << std::endl;
	}

	void GetString(const std::string& str)
	{
		std::cout << "receive both r and l value:" << str << std::endl;
	}
	//only receive lvalue
	void ReverseTraversal(std::string& str)
	{
		for (auto it = str.rbegin();it != str.rend();++it)
		{
			std::cout << *it;
		}
		std::cout << std::endl;
	}
	//only receive rvalue
	void Traversal(std::string&& str)
	{
		for (auto item : str)
		{
			std::cout << str;
		}
		std::cout << std::endl;
	}
};