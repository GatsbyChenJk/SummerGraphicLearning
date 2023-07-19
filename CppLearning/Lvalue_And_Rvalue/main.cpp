#include <iostream>
#include "InAndOut.h"

int main()
{
	InAndOut testInputOutput1;
	InAndOut testInputOutPut2 = InAndOut(123);
	InAndOut testInputOutPut3 = InAndOut("huanfafei");
	InAndOut testInputOutPut4 = InAndOut(11546, "aciancedc");

	//l and r integral test
	int i = 5;
	testInputOutput1.GetValue(i);//l
	testInputOutput1.GetValue(5);//r
	//l and r string test
	std::string s = "haofcie";
	testInputOutPut2.GetString(s);//l
	testInputOutPut2.GetString("gedvdg");//r

	testInputOutPut3.ReverseTraversal(s);
	//testInputOutPut3.ReverseTraversal("snsfesfacs");//error:parameter is r value

	testInputOutPut4.Traversal("acetaffy");
	//testInputOutPut4.Traversal(s);//error:parameter is l value
}