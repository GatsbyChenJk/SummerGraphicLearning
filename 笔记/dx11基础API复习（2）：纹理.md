# dx11基础API复习（2）：纹理

## 1.纹理坐标系

1）纹理坐标系的定义

纹理坐标系和屏幕、图片坐标系的有些相似，它们的U轴都是水平朝右，V轴竖直向下。但是纹理的X和Y的取值范围都为`[0.0, 1.0]`，分别映射到`[0, Width]`和`[0, Height]`，示意图如下：

![](C:\Users\25768\Pictures\Camera Roll\texcoord.png)

2）纹理坐标的表示

对于一个3D的三角形，通过给这三个顶点额外的纹理坐标信息，那么三个纹理坐标就可以映射到纹理指定的某片三角形区域。

这样的话已知三个顶点的坐标`p0`,`p1`和`p2`以及三个纹理坐标`q0`,`q1`和`q2`，就可以求出顶点坐标映射与纹理坐标的对应关系：
$$
(x,y,z)=\mathbf{p_0} + s(\mathbf{p_1} - \mathbf{p_0})+t(\mathbf{p_2}-\mathbf{p_1})
$$

$$
(u,v)=\mathbf{q_0}+s(\mathbf{q_1}-\mathbf{q_0})+t(\mathbf{q_2}-\mathbf{q_1})
$$

且s >= 0，t >= 0，s + t <= 1

示意图如下：

![](C:\Users\25768\Pictures\Camera Roll\texcoord2.png)

## 2.过滤器（Filter）

#### 1）使用情景：图片的放大和缩小

i.图片在经过**放大**操作后，除了图片原有的像素被拉伸，还需要对其余空缺的像素位置选用合适的方式来进行填充。比如一个2x2位图被拉伸成8x8的，除了角上4个像素，还需要对其余60个像素进行填充。

ii.图片在经过**缩小**操作后，需要抛弃掉一些像素。但显然每次绘制都按实际宽高来进行缩小会对性能有很大影响。 在d3d中可以使用mipmapping技术，以额外牺牲一些内存代价的方式来获得高效的拟合效果。

#### 2）图片放大后的处理方法

i.**常量插值法**

对于2x2位图，它的宽高表示范围都为`[0,1]`，而8x8位图的都为`[0,7]`，且只允许取整数。那么对于放大后的像素点`(1, 4)`就会映射到`(1/7, 4/7)`上。

常量插值法的做法十分简单粗暴，就是对X和Y值都进行四舍五入操作，然后取邻近像素点的颜色。比如对于映射后的值如果落在`[20.5, 21.5)`的范围，最终都会取21。根据上面的例子，最终会落入到像素点`(0, 1)`上，然后取该像素点的颜色。

这其实就是过滤器中的箱式过滤器（box filter）的应用

ii.1**线性插值法**

现在只讨论一维情况，已知第20个像素点的颜色`p0`和第21个像素点的颜色`p1`，并且经过拉伸放大后，有一个像素点落在范围`(20, 21)`之间，我们就可以使用线性插值法求出最终的颜色(t取`(0,1)`)：
$$
\mathbf{p}=t\mathbf{p_1}+(1-t)\mathbf{p_0}
$$
对于二维情况，会有三种使用线性插值法的情况：

1. X方向使用常量插值法，Y方向使用线性插值法
2. X方向使用线性插值法，Y方向使用常量插值法
3. X和Y方向均使用线性插值法

下图展示了双线性插值法的过程，已知4个相邻像素点，当前采样的纹理坐标在这四个点内，则首先根据x方向的纹理坐标进行线性插值，然后根据y方向的纹理坐标再进行一遍线性插值：

![](C:\Users\25768\Pictures\Camera Roll\lerp.png)

这其实就是帐篷过滤器（Tent Filter）的应用

ii.2两种插值方法的对比（左为常量插值，右为双线性插值）

![](C:\Users\25768\Pictures\Camera Roll\twoLerpCompare.png)

可见常量插值锯齿感明显，而双线性插值模糊感明显

#### 3）图片缩小后的处理

这里估计使用的是金字塔下采样的原理。一张256x256的纹理，通过不断的向下采样，可以获得256x256、128x128、64x64...一直到1x1的一系列位图，这些位图构建了一条mipmap链，并且不同的纹理标注有不同的mipmap等级

其中mipmap等级为0的纹理即为原来的纹理，等级为1的纹理所占内存为等级为0的1/4，等级为2的纹理所占内存为等级为1的1/4...以此类推我们可以知道包含完整mipmap的纹理占用的内存空间不超过原来纹理的
$$
\lim_{{n}\rightarrow{+\infty}}=\frac{1(1-(\frac{1}{4})^n)}{1-\frac{1}{4}}=\frac{4}{3}
$$
各级mipmap如图所示：

![](C:\Users\25768\Pictures\Camera Roll\mipmap.png)

接下来会有两种情况：

1. 选取mipmap等级对应图片和缩小后的图片大小最接近的一张，然后进行线性插值法或者常量插值法，这种方式叫做点过滤(point filtering)
2. 选取两张mipmap等级相邻的图片，使得缩小后的图片大小在那两张位图之间，然后对这两张位图进行常量插值法或者线性插值法分别取得颜色结果，最后对两个颜色结果进行线性插值，这种方式叫做线性过滤(linear filtering)。

#### 4）各向异性过滤

Anisotropic Filtering可以帮助我们处理那些不与屏幕平行的平面，需要额外使用平面的法向量和摄像机的观察方向向量。虽然使用该种过滤器会有比较大的性能损耗，但是能诞生出比较理想的效果。

下面左图使用了线性过滤法，右边使用的是各向异性过滤，可以看到顶面纹理比左边的更加清晰

![](C:\Users\25768\Pictures\Camera Roll\Anisotropic Filtering.png)

## 3.使用的主要api

#### 1.c++层面

1）读取纹理时可使用的两个方法：**CreateDDSTextureFromFile**方法和**CreateWICTextureFromFile**方法，使用这两种方法需要分别链接两个库：**DDSTextureLoader**和**WICTextureLoader**库。

i.**CreateDDSTextureFromFile**方法的参数列表为：

```cpp
HRESULT CreateDDSTextureFromFile(
    ID3D11Device* d3dDevice,                // [In]D3D设备
    const wchar_t* szFileName,              // [In]dds图片文件名
    ID3D11Resource** texture,               // [Out]输出一个指向资源接口类的指针，也可以填nullptr
    ID3D11ShaderResourceView** textureView, // [Out]输出一个指向着色器资源视图的指针，也可以填nullptr
    size_t maxsize = 0,                     // [In]忽略
    DDS_ALPHA_MODE* alphaMode = nullptr);  // [In]忽略
```

调用示例：

```cpp
// 初始化木箱纹理
HR(CreateDDSTextureFromFile(m_pd3dDevice.Get(), L"Texture\\WoodCrate.dds", nullptr, m_pWoodCrate.GetAddressOf()));
```

ii.**CreateWICTextureFromFile**方法的参数列表为：

```cpp
HRESULT CreateWICTextureFromFile(
    ID3D11Device* d3dDevice,                // [In]D3D设备
    const wchar_t* szFileName,              // [In]wic所支持格式的图片文件名
    ID3D11Resource** texture,               // [Out]输出一个指向资源接口类的指针，也可以填nullptr
    ID3D11ShaderResourceView** textureView, // [Out]输出一个指向着色器资源视图的指针，也可以填nullptr
    size_t maxsize = 0);                     // [In]忽略

```

调用示例：

```cpp
// 初始化火焰纹理
WCHAR strFile[40];
m_pFireAnims.resize(120);
for (int i = 1; i <= 120; ++i)
{
    wsprintf(strFile, L"Texture\\FireAnim\\Fire%03d.bmp", i);
    HR(CreateWICTextureFromFile(m_pd3dDevice.Get(), strFile, nullptr, m_pFireAnims[i - 1].GetAddressOf()));
}
```

2）**ID3D11DeviceContext::*SSetShaderResources**方法，设置着色器资源，用于将读取的纹理传入HLSL中设置的存储纹理的变量，以像素着色器为例，参数列表为：

```cpp
void ID3D11DeviceContext::PSSetShaderResources(
    UINT StartSlot,    // [In]起始槽索引，对应HLSL的register(t*)
    UINT NumViews,    // [In]着色器资源视图数目
    ID3D11ShaderResourceView * const *ppShaderResourceViews    // [In]着色器资源视图数组
);
```

调用示例（以上面读取的木箱纹理为例）

```cpp
m_pd3dImmediateContext->PSSetShaderResources(0, 1, m_pWoodCrate.GetAddressOf());
```

3）**ID3D11Device::CreateSamplerState**方法，用于创建采样器状态，参数列表为：

```cpp
HRESULT ID3D11Device::CreateSamplerState( 
    const D3D11_SAMPLER_DESC *pSamplerDesc, // [In]采样器状态描述
    ID3D11SamplerState **ppSamplerState);   // [Out]输出的采样器
```

其中采样器状态`D3D11_SAMPLER_DESC`描述采样器信息的结构体，定义如下：

```cpp
typedef struct D3D11_SAMPLER_DESC
{
    D3D11_FILTER Filter;                    // 所选过滤器
    D3D11_TEXTURE_ADDRESS_MODE AddressU;    // U方向寻址模式
    D3D11_TEXTURE_ADDRESS_MODE AddressV;    // V方向寻址模式
    D3D11_TEXTURE_ADDRESS_MODE AddressW;    // W方向寻址模式
    FLOAT MipLODBias;   // mipmap等级偏移值，最终算出的mipmap等级会加上该偏移值
    UINT MaxAnisotropy;                     // 最大各向异性等级(1-16)
    D3D11_COMPARISON_FUNC ComparisonFunc;   // 这节不讨论
    FLOAT BorderColor[ 4 ];     // 边界外的颜色，使用D3D11_TEXTURE_BORDER_COLOR时需要指定
    FLOAT MinLOD;   // 若mipmap等级低于MinLOD，则使用等级MinLOD。最小允许设为0
    FLOAT MaxLOD;   // 若mipmap等级高于MaxLOD，则使用等级MaxLOD。必须比MinLOD大        
}     D3D11_SAMPLER_DESC;
```

`D3D11_FILTER`为枚举类型，枚举值如下：

| 枚举值                                      | 缩小     | 放大     | mipmap   |
| ------------------------------------------- | -------- | -------- | -------- |
| D3D11_FILTER_MIN_MAG_MIP_POINT              | 点采样   | 点采样   | 点采样   |
| D3D11_FILTER_MIN_MAG_POINT_MIP_LINEAR       | 点采样   | 点采样   | 线性采样 |
| D3D11_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT | 点采样   | 线性采样 | 点采样   |
| D3D11_FILTER_MIN_MAG_MIP_LINEAR             | 线性采样 | 线性采样 | 线性采样 |
| D3D11_FILTER_ANISOTROPIC                    | 各向异性 | 各向异性 | 各向异性 |

`D3D11_TEXTURE_ADDRESS_MODE`是单个方向的寻址模式，有时候纹理坐标会超过1.0或者小于0.0，这时候寻址模式可以解释边界外的情况，通过不同枚举值说明：

1.`D3D11_TEXTURE_ADDRESS_WRAP`是将指定纹理坐标分量的值[t, t + 1], t ∈ Z映射到[0.0, 1.0]，因此作用到u和v分量时看起来就像是把用一张贴图紧密平铺到其他位置上

2.`D3D11_TEXTURE_ADDRESS_MIRROR`在每个整数点处翻转纹理坐标值。例如u在[0.0, 1.0]按正常纹理坐标寻址，在[1.0, 2.0]内则翻转，在[2.0, 3.0]内又回到正常的寻址

3.`D3D11_TEXTURE_ADDRESS_CLAMP`对指定纹理坐标分量，小于0.0的值都取作0.0，大于1.0的值都取作1.0，在[0.0, 1.0]的纹理坐标不变

4.`D3D11_TEXTURE_BORDER_COLOR`对于指定纹理坐标分量的值在[0.0, 1.0]外的区域都使用`BorderColor`进行填充

5.`D3D11_TEXTURE_ADDRESS_MIRROR_ONCE`相当于MIRROR和CLAMP的结合，仅[-1.0,1.0]的范围内镜像有效，若小于-1.0则取-1.0，大于1.0则取1.0，在[-1.0, 0.0]进行翻转

创建采样器状态并调用该方法的示例：

```cpp
// 初始化采样器状态描述
D3D11_SAMPLER_DESC sampDesc;
ZeroMemory(&sampDesc, sizeof(sampDesc));
sampDesc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
sampDesc.AddressU = D3D11_TEXTURE_ADDRESS_WRAP;
sampDesc.AddressV = D3D11_TEXTURE_ADDRESS_WRAP;
sampDesc.AddressW = D3D11_TEXTURE_ADDRESS_WRAP;
sampDesc.ComparisonFunc = D3D11_COMPARISON_NEVER;
sampDesc.MinLOD = 0;
sampDesc.MaxLOD = D3D11_FLOAT32_MAX;
HR(m_pd3dDevice->CreateSamplerState(&sampDesc, m_pSamplerState.GetAddressOf()));
```

4）**ID3D11DeviceContext::*SSetSamplers**方法，设置采样器状态，使创建好的采样器传入HLSL中存储采样器的变量，这里以像素着色器为例：

```cpp
void ID3D11DeviceContext::PSSetSamplers(
    UINT StartSlot,     // [In]起始槽索引
    UINT NumSamplers,   // [In]采样器状态数目
    ID3D11SamplerState * const * ppSamplers);   // [In]采样器数组  
```

调用示例：

```cpp
// 像素着色阶段设置好采样器
m_pd3dImmediateContext->PSSetSamplers(0, 1, m_pSamplerState.GetAddressOf());
```

#### 2.HLSL层面

*.**Texture2D类中的Sample方法**

参数列表为：

```cpp
float4 Sample(
SamplerState g_SamLinear, //[In]采样器状态
float2 g_Tex)             //[In]纹理坐标（uv）
```

使用示例：

```cpp
//"Basic.hlsli"
//在头文件中创建全局变量并绑定对应寄存器
Texture2D gTex : register(t0);
SamplerState gSamLinear : register(s0);
//相应结构体定义
struct VertexPosHTex
{
    float4 PosH : SV_POSITION;
    float2 Tex : TEXCOORD;
};
//输出纹理颜色的像素着色器
// Basic_PS_2D.hlsl
#include "Basic.hlsli"

// 像素着色器(2D)
float4 PS_2D(VertexPosHTex pIn) : SV_Target
{
    return g_Tex.Sample(g_SamLinear, pIn.Tex);
}
```

