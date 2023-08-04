#pragma once
#include <iostream>
#include <memory>

//抽象工厂模式

//产品一：“顶点数据”
class VertexData
{
public :
	virtual ~VertexData() {}

	virtual std::string ShowVertex() const = 0;

	std::string MVP_Transform()
	{
		return "Using MVP matrix to transforming vertex coordination";
	}

	std::string ShaderProcess()
	{
		return "the shaders processing the data";
	}

	std::string Rasterization()
	{
		return "The hardwares utilzing the lerp algorithm to shading";
	}


};

class TriangleVertexData : public VertexData
{
public :
	std::string ShowVertex() const override
	{
		//
		// * 
		// *	*
		// *		*
		// *	*	*	*
		//
		std::string vertex = "\n*\n*\t*\n*\t\t*\n*\t*\t*\t*\t*\n";
		return vertex;
	}
};

class RectangleVertexData : public VertexData
{
public:
	std::string ShowVertex() const override
	{
		//
		// *		*
		// 
		//
		// *		*
		//
		std::string vertex = "\n*\t\t*\n\n*\t\t*\n";
		return vertex;
	}
};


//产品二：“缓冲区数据”
class BufferData
{
public:
	virtual ~BufferData() {}

	virtual std::string BufferType() const = 0;

	std::string FillBufferDesc()
	{
		return "Filling buffer description";
	}

	std::string InitializingBufferData()
	{
		return "Creating buffer data and assigning";
	}

	std::string CreateBuffer()
	{
		return "Using API to create buffer";
	}
};

class VertexBufferData : public BufferData
{
public :
	std::string BufferType() const override
	{
		return "[Buffer Type] : Vertex Buffer";
	}
};

class ConstantBufferData : public BufferData
{
public:
	std::string BufferType() const override
	{
		return "[Buffer Type] : Constant Buffer";
	}
};


//抽象工厂类：“渲染器”
class Renderer
{
public :  
	virtual VertexData* VertexRender() const = 0;

	virtual BufferData* BufferCreator() const = 0;

	std::string RenderingPipeline() const
	{
		VertexData* vert = this->VertexRender();
		std::cout << vert->MVP_Transform() << std::endl;
		std::cout << vert->ShaderProcess() << std::endl;
		std::cout << vert->Rasterization() << std::endl;

		std::cout << std::endl;

		BufferData* buff = this->BufferCreator();
		std::cout << buff->FillBufferDesc() << std::endl;
		std::cout << buff->InitializingBufferData() << std::endl;
		std::cout << buff->CreateBuffer() << std::endl;

		std::string result = "[Render result] ; " + vert->ShowVertex() + "using buffer :" + buff->BufferType();
		delete vert;
		delete buff;
		return result;
	}
};

class TriangleRenderer : public Renderer
{
public:
	VertexData* VertexRender() const override
	{
		return new TriangleVertexData();
	}

	BufferData* BufferCreator() const override
	{
		return new VertexBufferData();
	}
};

class RectangleRenderer : public Renderer
{
public :
	VertexData* VertexRender() const override
	{
		return new RectangleVertexData();
	}

	BufferData* BufferCreator() const override
	{
		return new ConstantBufferData();
	}
};

void UserOperation(const Renderer& Renderer)
{
	std::cout << "The User just launched a rendering" << std::endl;
	std::cout << Renderer.RenderingPipeline() << std::endl;

}