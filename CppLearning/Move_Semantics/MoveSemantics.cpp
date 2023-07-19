#include "TestInt.h"

int main()
{
	TestInt test_data = TestInt(123);
	TestInt test_other = TestInt(456);	

    //未使用移动语义
	test_data.ProcessVector(test_other);
	//test_data.Traversal();

	//使用移动语义
	test_data.ProcessVector(std::move(test_other));
	//test_data.Traversal();
}