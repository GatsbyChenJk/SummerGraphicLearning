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
	//���ÿ������캯��
	Single(const Single& other) = delete;
	//���ø�ֵ������
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

// ��̬��Ա������Ҫ�����ⲿ���ж���ͳ�ʼ��
Single* Single::single_ptr = nullptr;

//��̬����ֻ�������ⲿ����
Single* Single::GetInstance(const int& value)
{
	if (single_ptr == nullptr)
	{
		single_ptr = new Single(value);
	}

	return single_ptr;
}