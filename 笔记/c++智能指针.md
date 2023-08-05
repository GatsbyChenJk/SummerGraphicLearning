# c++智能指针

## 1.简单概念

在c++中，智能指针分为三种，它们分别是unique_ptr，shared_ptr，weak_ptr，三种指针的简单介绍和区别如下：

在C++中，`unique_ptr`、`shared_ptr`和`weak_ptr`是三种智能指针，它们都提供了对动态分配的对象的管理和所有权控制。它们之间的区别如下：

1. `unique_ptr`：`unique_ptr`是独占所有权的智能指针，它确保只有一个指针可以拥有和管理对象。它不能被复制，但可以通过移动语义转移所有权。当`unique_ptr`超出其作用域时，它会自动删除所管理的对象。这种独占性使得`unique_ptr`非常适合管理动态分配的资源，如堆上的对象或数组。

2. `shared_ptr`：`shared_ptr`是共享所有权的智能指针，它可以被多个指针共享和拥有同一个对象。它使用引用计数来跟踪有多少个`shared_ptr`指向同一个对象。只有当最后一个`shared_ptr`超出其作用域时，才会删除所管理的对象。`shared_ptr`可以通过复制来共享所有权，并且可以通过`reset()`函数来释放所有权。然而，循环引用可能导致内存泄漏，因为引用计数无法降为零。

3. `weak_ptr`：`weak_ptr`是一种弱引用智能指针，它用于解决`shared_ptr`的循环引用问题。`weak_ptr`可以观测和访问由`shared_ptr`管理的对象，但它不会增加引用计数。当最后一个`shared_ptr`超出其作用域时，即使有`weak_ptr`指向对象，对象也会被销毁。`weak_ptr`可以通过`lock()`函数获取一个有效的`shared_ptr`，以便安全地访问对象。

总结：
- `unique_ptr`提供独占所有权，适用于单一所有者的情况。

- `shared_ptr`提供共享所有权，适用于多个所有者的情况。

- `weak_ptr`是`shared_ptr`的观测指针，用于解决循环引用问题。

  # 2.unique_ptr的简单使用

这里构造了一个基于unique指针的简单测试类

```cpp
#pragma once
#include <memory>
#include <iostream>

class TestClass
{
private:
	std::unique_ptr<int> testData;//声明
public:
	TestClass()
	{
		testData = nullptr;
	}

	TestClass(int data)
	{
		testData = std::make_unique<int>(data);//赋值
		std::cout << data << " has been created!" << std::endl;
	}
	~TestClass()
	{
		std::cout << "Destructor called" << std::endl;
	}
};
```

在实际运行时，采用栈和堆两种内存分配方式测试

首先是栈上分配内存，指针会自动解引用

```cpp
#include "test.h"
int main()
{
	//栈上分配
	TestClass DataTest1;
}
```

![image-20230717112114984](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230717112114984.png)

而如果在堆上分配，必须加上delete才能在程序生命周期结束后调用析构函数释放内存

```cpp
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
```

![image-20230717112256349](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230717112256349.png)