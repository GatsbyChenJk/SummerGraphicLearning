# c++类中的隐藏函数

在C++中，隐藏函数是指在派生类中定义了与基类中同名的成员函数，从而隐藏了基类中的同名函数。当派生类对象通过派生类类型的指针或引用调用该函数时，将只能访问到派生类中定义的函数，而无法访问基类中的同名函数。

隐藏函数的特点如下：

1. 隐藏函数只会在派生类中隐藏基类中的同名函数，而不会影响其他基类中的同名函数。

2. 隐藏函数只会在派生类中隐藏基类中的同名函数，而不会覆盖基类中的同名函数。这意味着，如果你在派生类中定义了一个与基类中同名的函数，那么基类中的同名函数仍然存在，只是被隐藏了。

3. 隐藏函数的调用取决于对象的静态类型。如果通过基类类型的指针或引用调用隐藏函数，将只能访问到基类中的同名函数。如果通过派生类类型的指针或引用调用隐藏函数，将只能访问到派生类中定义的函数。

为了避免函数的隐藏，可以使用`using`关键字来引入基类中的同名函数，使其在派生类中可见。例如：

```cpp
class Base {
public:
    void foo() {
        std::cout << "Base::foo()" << std::endl;
    }
};

class Derived : public Base {
public:
    void foo() {
        std::cout << "Derived::foo()" << std::endl;
    }

    using Base::foo; // 引入基类中的同名函数
};
```

在上面的例子中，通过使用`using Base::foo;`语句，我们在派生类中引入了基类中的同名函数。这样，无论是通过基类类型还是派生类类型的指针或引用调用`foo()`函数，都可以访问到基类中的同名函数。