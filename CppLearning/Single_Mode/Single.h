#pragma once
#include <vector>
#include <iostream>

class Single
{
protected:
	std::vector<int> m_data;
	static Single* single_ptr;
protected:
	Single(const int& value)
		:m_data{ value }
	{}
public:
	//禁用拷贝构造函数
	Single(const Single& other) = delete;
	//禁用赋值操作符
	void operator= (const Single&) = delete;

	static Single* GetInstance(const int& value);

	void BussinessLogic()
	{
		for (auto& element : m_data)
		{
			std::cout << element << std::endl;
		}
	}
};

// 静态成员变量需要在类外部进行定义和初始化
Single* Single::single_ptr = nullptr;

//静态方法只能在类外部定义
Single* Single::GetInstance(const int& value)
{
	if (single_ptr == nullptr)
	{
		single_ptr = new Single(value);
	}

	return single_ptr;
}