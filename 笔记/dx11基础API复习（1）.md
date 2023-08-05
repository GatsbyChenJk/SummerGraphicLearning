# dx11基础API复习（1）

## 1.前置知识：简易的渲染管线结构

一个简易的dx11渲染管线可表示为下图，其中矩形为不可编程的阶段，椭圆形为可编程的阶段

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/singleRP.png)

## 输入装配阶段

输入装配阶段会从显存中读取顶点和索引（如果有）数据，再将它们装配成几何图元。通常用到的图元拓扑有点、线段和三角形。

## 顶点着色器阶段

待图元被装配完毕后，其顶点就会被送入到顶点着色器阶段。我们可以把顶点着色器看作一种输入与输出皆为单个顶点的函数，只是输入的顶点和输出的顶点不仅内容上可能有变化，顶点包含的属性也可能有变化。

我们可以利用顶点着色器来实现许多特效，例如变换、光照和置换贴图。在顶点着色器中，不但可以访问输入的顶点数据，也能够访问纹理和其他存于显存中的数据（如变换矩阵与场景的光照信息）。

## 光栅化阶段

光栅化阶段需要完成的任务很多，其中包括对输出的顶点进行**视口变换**，这样x、y坐标都将以像素为单位表示。然后根据原顶点和图元，确定当前图元会出现在待绘制纹理的哪些像素位置上，根据图元的顶点信息，并利用**透视校正插值法**来计算出像素片段（pixel fragment）的位置、颜色（如果有）等信息。

对于三角形来说，不同的顶点顺序有不同的含义。默认情况下，三角形的顶点绕顺时针排布时（从摄像机朝着该三角形看）则说明当前三角形的面朝向当前摄像机，而三角形的顶点绕逆时针排布则说明当前三角形的面背对当前摄像机。对于背朝摄像机的三角形会被剔除，从而不进行光栅化。这种做法叫**背面消隐**。

在光栅化的时候，每个像素都是以它的中点位置进行插值计算的。如下图所示，若只有2x2的像素，黑色顶点为构成三角形的顶点，蓝色顶点则为光栅化时选择的顶点以及插值计算得到的结果。

![img](https://img2018.cnblogs.com/blog/1172605/202001/1172605-20200109002327417-1676348200.png)

## 像素着色器阶段

作为可编程着色器阶段，它会针对每一个像素片段进行处理（每处理一个像素就要执行一次像素着色器）。它既可以直接返回一种单一的恒定颜色，也可以实现如逐像素光照、反射及阴影等更为复杂的效果

## 输出合并阶段

通过像素着色器生成的像素片段会被移送至渲染管线的输出合并阶段。在这个阶段中，一些像素片段需要经过**模板测试**和**深度测试**来确定是否能留下，然后必要的时候还需要与绑定的缓冲区对应像素片段进行**混合操作**，可以实现透明等效果

# 2.输入布局

## 1）主要api介绍

i.我们可以使用**ID3D11Device::CreateInputLayout()**方法来创建一个输入布局，其输入输出参数如下所示：

```cpp
HRESULT ID3D11Device::CreateInputLayout( 
    const D3D11_INPUT_ELEMENT_DESC *pInputElementDescs, // [In]输入布局描述
    UINT NumElements,                                   // [In]上述数组元素个数
    const void *pShaderBytecodeWithInputSignature,      // [In]顶点着色器字节码
    SIZE_T BytecodeLength,                              // [In]顶点着色器字节码长度
    ID3D11InputLayout **ppInputLayout);                 // [Out]获取的输入布局

```

ii.创建好了一个输入布局，我们可以通过**ID3D11DeviceContext::IASetInputLayout()**方法来接收创建好的输入布局并设置该输入布局，其函数形式为：

```cpp
void ID3D11DeviceContext::IASetInputLayout( 
    ID3D11InputLayout *pInputLayout);   // [In]输入布局

```

## 2）实际应用举例

当我们在GPU层面创建了相应的HLSL顶点数据结构体和CPU层面（c++）的顶点数据结构体（如下图）

```cpp
struct VertexIn
{
    float3 pos : POSITION;
    float4 color : COLOR;
};

```

```cpp
struct VertexPosColor
{
    DirectX::XMFLOAT3 pos;
    DirectX::XMFLOAT4 color;
    //静态成员，不属于结构体
    static const D3D11_INPUT_ELEMENT_DESC inputLayout[2];
};

```

之后我们需要将HLSL中的顶点数据和C++中的顶点数据建立对应关系，需要使用到`ID3D11InputLayout`类里的方法和结构体来描述顶点数据结构体中成员的语义、用途等信息。

我们首先要用到`D3D11_INPUT_ELEMENT_DESC`结构体来描述待传入结构体（HLSL中的结构体）的成员具体信息：

```cpp
typedef struct D3D11_INPUT_ELEMENT_DESC
{
    LPCSTR SemanticName;        // 语义名
    UINT SemanticIndex;         // 语义索引
    DXGI_FORMAT Format;         // 数据格式
    UINT InputSlot;             // 输入槽索引(0-15)
    UINT AlignedByteOffset;     // 初始位置(字节偏移量)
    D3D11_INPUT_CLASSIFICATION InputSlotClass; // 输入类型
    UINT InstanceDataStepRate;  // 忽略
}     D3D11_INPUT_ELEMENT_DESC;

```

然后通过静态成员inputLayout描述信息，填充结构体

```cpp
const D3D11_INPUT_ELEMENT_DESC VertexPosColor::inputLayout[2] = {
    { "POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0 },
    { "COLOR", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 12, D3D11_INPUT_PER_VERTEX_DATA, 0}
};

```

在创建完顶点着色器后，就是创建和绑定顶点布局，代码如下所示：

```cpp
// 创建并绑定顶点布局
    HR(m_pd3dDevice->CreateInputLayout(VertexPosColor::inputLayout, ARRAYSIZE(VertexPosColor::inputLayout),
        blob->GetBufferPointer(), blob->GetBufferSize(), m_pVertexLayout.GetAddressOf()));
```

然后再设置输入布局的时候就会再初始化资源时使用另一个方法

```cpp
m_pd3dImmediateContext->IASetInputLayout(m_pVertexLayout.Get());
```

# 3.创建着色器和缓冲区

## 1）主要api介绍

i.**ID3D11Device::CreateXXXXShader**方法用于创建着色器，其中XXXX代表不同类型的着色器，如下表所示：

![image-20230719174535773](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230719174535773.png) 

这里简单介绍顶点着色器的参数

```cpp
HRESULT ID3D11Device::CreateVertexShader( 
    const void *pShaderBytecode,            // [In]着色器字节码
    SIZE_T BytecodeLength,                  // [In]字节码长度
    ID3D11ClassLinkage *pClassLinkage,      // [In_Opt]忽略
    ID3D11VertexShader **ppVertexShader);   // [Out]获取顶点着色器

```

ii.通过**ID3D11Device::CreateBuffer**方法我们可以创建一个缓冲区，其输入输出参数为

```cpp
HRESULT ID3D11Device::CreateBuffer( 
    const D3D11_BUFFER_DESC *pDesc,     // [In]顶点缓冲区描述
    const D3D11_SUBRESOURCE_DATA *pInitialData, // [In]子资源数据
    ID3D11Buffer **ppBuffer);           // [Out] 获取缓冲区
```

## 2）实际应用

在GameApp::InitEffect方法中创建着色器

```cpp
// 创建顶点着色器    
HR(CreateShaderFromFile(L"HLSL\\Triangle_VS.cso", L"HLSL\\Triangle_VS.hlsl", "VS", "vs_5_0", blob.ReleaseAndGetAddressOf()));
    HR(m_pd3dDevice->CreateVertexShader(blob->GetBufferPointer(), blob->GetBufferSize(), nullptr, m_pVertexShader.GetAddressOf()));
```

```cpp
 // 创建像素着色器    
HR(CreateShaderFromFile(L"HLSL\\Triangle_PS.cso", L"HLSL\\Triangle_PS.hlsl", "PS", "ps_5_0", blob.ReleaseAndGetAddressOf()));
    HR(m_pd3dDevice->CreatePixelShader(blob->GetBufferPointer(), blob->GetBufferSize(), nullptr, m_pPixelShader.GetAddressOf()));
```

在GameApp::InitResource方法中，创建一个缓冲区首先需要通过`D3D11_BUFFER_DESC`结构体创建一个缓冲区描述，接着使用结构体`D3D11_SUBRESOURCE_DATA`填充初始化数据,两个结构体分别定义如下：

```cpp
typedef struct D3D11_BUFFER_DESC
{
    UINT ByteWidth;             // 数据字节数
    D3D11_USAGE Usage;          // CPU和GPU的读写权限相关
    UINT BindFlags;             // 缓冲区类型的标志
    UINT CPUAccessFlags;        // CPU读写权限的指定
    UINT MiscFlags;             // 忽略
    UINT StructureByteStride;   // 忽略
}     D3D11_BUFFER_DESC;

```

```cpp
typedef struct D3D11_SUBRESOURCE_DATA
{
    const void *pSysMem;        // 用于初始化的数据
    UINT SysMemPitch;           // 忽略
    UINT SysMemSlicePitch;      // 忽略
}     D3D11_SUBRESOURCE_DATA;

```

下面以创建一个顶点缓冲区为例说明，首先设置顶点缓冲区描述如下：

```cpp
// 设置顶点缓冲区描述
D3D11_BUFFER_DESC vbd;
ZeroMemory(&vbd, sizeof(vbd));
vbd.Usage = D3D11_USAGE_IMMUTABLE;
vbd.ByteWidth = sizeof vertices;
vbd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
vbd.CPUAccessFlags = 0;
```

接着初始化数据

```cpp
// 新建顶点缓冲区
D3D11_SUBRESOURCE_DATA InitData;
ZeroMemory(&InitData, sizeof(InitData));
InitData.pSysMem = vertices;
```

最后通过CreateBuffer方法创建顶点缓冲区

```cpp
ComPtr<ID3D11Buffer> m_pVertexBuffer = nullptr;
HR(m_pd3dDevice->CreateBuffer(&vbd, &InitData, m_pVertexBuffer.GetAddressOf()));
```

# 4.输入装配阶段设置

## 1）主要api

在第二节我们提到了**ID3D11DeviceContext::IASetInputLayout**

方法，这是输入装配阶段中使用到的方法之一，除此之外，还有几个重要的方法，下面一一介绍。

i.设置某一渲染阶段的着色器使用的是**ID3D11DeviceContext::*SSetShader**方法，其中*号代表`v` ，`H`，`D`，`C`，`G`，`P`，比如像V就代表顶点着色器，其输入输出参数如下所示：

```cpp
void ID3D11DeviceContext::VSSetShader( 
    ID3D11VertexShader *pVertexShader,              // [In]顶点着色器
    ID3D11ClassInstance *const *ppClassInstances,   // [In_Opt]忽略
    UINT NumClassInstances);                        // [In]忽略
```

 ii.设置图元类型使用的是**ID3D11DeviceContext::IASetPrimitiveTopology**方法，参数形式为：

```cpp
void ID3D11DeviceContext::IASetPrimitiveTopology( 
    D3D11_PRIMITIVE_TOPOLOGY Topology);     // [In]图元类型
```

其参数为一些枚举值，如下表所示：

![image-20230719190607608](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230719190607608.png)

iii.设置顶点缓冲区使用的是**ID3D11DeviceContext::IASetVertexBuffers**方法，其输入输出参数如下所示：

```cpp
void ID3D11DeviceContext::IASetVertexBuffers( 
    UINT StartSlot,     // [In]输入槽索引
    UINT NumBuffers,    // [In]缓冲区数目
    ID3D11Buffer *const *ppVertexBuffers,   // [In]指向缓冲区数组的指针
    const UINT *pStrides,   // [In]一个数组，规定了对所有缓冲区每次读取的字节数分别是多少
    const UINT *pOffsets);  // [In]一个数组，规定了对所有缓冲区的初始字节偏移量

```

## 2）实际应用

在GameApp::InitResource中，对于已经创建的顶点着色器和像素着色器可以这样使用**ID3D11DeviceContext::*SSetShader**方法

```cpp
// 将着色器绑定到渲染管线
    m_pd3dImmediateContext->VSSetShader(m_pVertexShader.Get(), nullptr, 0);
    m_pd3dImmediateContext->PSSetShader(m_pPixelShader.Get(), nullptr, 0);
```

将图元类型设置为按顺序每三个点构成三角形装配，可以使用枚举值中的**D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST**枚举值作为参数传入**ID3D11DeviceContext::IASetPrimitiveTopology**方法

```cpp
 // 设置图元类型，设定输入布局
    m_pd3dImmediateContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
```

在基于上一节的例子创建的顶点缓冲区，可以使用**ID3D11DeviceContext::IASetVertexBuffers**方法设置顶点缓冲区

```cpp
// 输入装配阶段的顶点缓冲区设置
    UINT stride = sizeof(VertexPosColor);	// 跨越字节数
    UINT offset = 0;						// 起始偏移量

    m_pd3dImmediateContext->IASetVertexBuffers(0, 1, m_pVertexBuffer.GetAddressOf(), &stride, &offset);
```

# 5.绘制画面

## 1）使用的api

**ID3D11DeviceContext::Draw**方法，可以通过已经创建的顶点缓冲区进行绘制，且无需提供索引缓冲区，其输入输出参数为

```cpp
void ID3D11DeviceContext::Draw( 
    UINT VertexCount,           // [In]需要绘制的顶点数目
    UINT StartVertexLocation);  // [In]起始顶点索引
```

调用该方法后，从输入装配阶段开始，该绘制的进行将会经历一次完整的渲染管线阶段，直到输出合并阶段为止。

通过指定`VertexCount`和`StartVertexLocation`的值我们可以按顺序绘制从索引`StartVertexLocation`到`StartVertexLocation + VertexCount - 1`的顶点

## 2）使用举例

在基于前面几节的创建和设置，我们可以绘制出一个三角形，通过Draw方法在GameApp::DrawScene方法内完成最终的步骤

```cpp
// 绘制三角形
    m_pd3dImmediateContext->Draw(3, 0);
```

