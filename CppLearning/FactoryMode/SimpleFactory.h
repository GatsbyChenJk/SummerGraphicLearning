#pragma once
#include <iostream>
#include <memory>


//产品类
class DrinkProduct
{
public:
	virtual ~DrinkProduct() {}
	//const修饰符：使方法不能修改类中成员
	//“= 0”表示该方法为纯虚函数，即接口
	//具体实现由子类实现
	virtual std::string ProductInfo() const = 0;

	std::string CreateBottle()
	{
		return "Bottle created";
	}

	std::string Filling()
	{
		return "Filling the drink into bottle";
	}

	std::string Delivering()
	{
		return "Delivering to the client";
	}

};

class LemonTeaProduct : public DrinkProduct
{
public:
	std::string ProductInfo () const override
	{
		return "Product type : [ Lemon Tea ]";
	}
};

class MilkTeaProduct : public DrinkProduct
{
public :
	std::string ProductInfo() const override
	{
		return "Product type : [ Milk Tea ]";
	}
};

//工厂类
class DrinkFactory
{
public:
	virtual ~DrinkFactory() {}

	virtual DrinkProduct* CreateDrink() const = 0;	

	std::string MakingPipeLine() const
	{
		DrinkProduct* DrinkProduct = this->CreateDrink();
		std::cout << DrinkProduct->CreateBottle() << std::endl;
		std::cout << DrinkProduct->Filling() << std::endl;
		std::cout << DrinkProduct->Delivering() << std::endl;
		std::string result = "The Client Product Info :" + DrinkProduct->ProductInfo();
		
		delete DrinkProduct;
		return result;
	}
};

class LemonTeaFactory : public DrinkFactory
{
public:
	DrinkProduct* CreateDrink() const override
	{
		return new LemonTeaProduct();
	}
};

class MilkTeaFactory : public DrinkFactory
{
public:
	DrinkProduct* CreateDrink() const override
	{
		return new MilkTeaProduct();
	}
};

void ClientOrdering(const DrinkFactory& DrinkFactory)
{
	std::cout << "Client is unaware of class strucure" << std::endl;
	std::cout << DrinkFactory.MakingPipeLine() << std::endl;
}