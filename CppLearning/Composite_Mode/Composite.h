#pragma once
#include <iostream>
#include <list>
#include <string>

 
class Component
{
protected:
	Component* Entity;
public:
	void SetComponent(Component* component)
	{
		this->Entity = component;
	}
	Component* GetComponent() const
	{
		return this->Entity;
	}
	//避免释放资源时派生类资源不能正常释放
	virtual ~Component()
	{}
	//特定派生类需要重写方法，因此基类应将方法设为虚方法
	virtual void Add(Component* AddComponent){}

	virtual void Remove(Component* RemoveComponent){}
	//使用const关键字保证不会对变量值修改
	virtual bool IsComposite() const
	{
		return false;
	}

	virtual std::string ComponentInfo() const = 0;

};

class SingleComponent : public Component
{
public:
	std::string ComponentInfo() const override
	{
		return "This is a Single Component";
	}
};

class ComplexComponent : public Component
{
protected :
	std::list<Component*> ComplexEntity;
public :
	void Add(Component* component) override
	{
		this->ComplexEntity.push_back(component);
		SetComponent(this);
	}
	void Remove(Component* component) override
	{
		this->ComplexEntity.remove(component);
		SetComponent(this);
	}
	bool IsComposite() const override
	{
		return true;
	}
	std::string ComponentInfo() const override
	{
		return "This is a complex component";
	}
};

void ClientCheckCompnonetType(Component* checkComp)
{
	std::cout << checkComp->ComponentInfo() << std::endl;
}