#include "TestInt.h"

int main()
{
	TestInt test_data = TestInt(123);
	TestInt test_other = TestInt(456);	

    //δʹ���ƶ�����
	test_data.ProcessVector(test_other);
	//test_data.Traversal();

	//ʹ���ƶ�����
	test_data.ProcessVector(std::move(test_other));
	//test_data.Traversal();
}