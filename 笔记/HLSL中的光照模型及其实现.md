# HLSL中的光照模型及其实现

# 1.基础模型

### 1）环境光（ambient）

$$
L_a=I_a\otimes m_a
$$

该式表示两向量各分量相乘，其中I_{a}和 m_{a}分别代表环境光的颜色向量和物体材质的颜色向量。

### 2）漫反射（diffuse）

$$
L_d = k_d * I_d \otimes m_d
$$

其中
$$
k_d=max(0,\hat{n} \cdot \hat{I})
$$
该式中k_{d}表示漫反射光照强度

### 3）高光镜面反射（specular）

$$
L_s = k_s *I_s \otimes m_s
$$

其中
$$
k_s = \begin{cases}
max(0,\vec{r} \cdot \hat{v})^{p} &&,\vec{L}\cdot \hat{n}>0\\
0 &&,\vec{L}\cdot\hat{n}<=0

\end{cases}
$$

### 4）基础光照模型（方向光/平行光）

$$
litColor = L_a + L_d + L_s
$$

# 2.三种光照模型及其计算方式的具体实现

### 1）方向光

结构体定义：

```cpp
struct DirectionalLight
{
    float4 Ambient;
    float4 Diffuse;
    float4 Specular;
    float3 Direction;
    float Pad;
};
```

计算方式的实现：

```cpp
void ComputeDirectionalLight(Material mat, DirectionalLight L,
    float3 normal, float3 toEye,
    out float4 ambient,
    out float4 diffuse,
    out float4 spec)
{
    // 初始化输出
    ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
    diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
    spec = float4(0.0f, 0.0f, 0.0f, 0.0f);

    // 光向量与照射方向相反
    float3 lightVec = -L.Direction;

    // 添加环境光
    ambient = mat.Ambient * L.Ambient;

    // 添加漫反射光和镜面光
    float diffuseFactor = dot(lightVec, normal);

    // 展开，避免动态分支
    [flatten]
    if (diffuseFactor > 0.0f)
    {
        float3 v = reflect(-lightVec, normal);
        float specFactor = pow(max(dot(v, toEye), 0.0f), mat.Specular.w);

        diffuse = diffuseFactor * mat.Diffuse * L.Diffuse;
        spec = specFactor * mat.Specular * L.Specular;
    }
}

```

### 2）点光

i.点光模型简单介绍：

点光与方向光不同，是一种会光照强度（I）随着离光源距离（d）逐渐增大而衰减的光，其衰减关系如下：
$$
I(d)=\frac{I_0}{a_{0}+a_1d+a_2d^2}
$$
当距离过远，由于
$$
\lim \limits_{d \to +\infty}I(d)=0
$$
所以在实现时会采用`Range`来控制点光照射的范围，减少不必要的计算。

那么点光的模型可表示如下：
$$
litColor = L_a + \frac{ L_d + L_s}{a_0+a_1d+a_2d^2}
$$
ii.点光模型的光照计算

结构体定义：

```cpp
// 点光
struct PointLight
{
    float4 Ambient;
    float4 Diffuse;
    float4 Specular;

    float3 Position;
    float Range;

    float3 Att;
    float Pad;
};
```

计算的实现：

```cpp
void ComputePointLight(Material mat, PointLight L, float3 pos, float3 normal, float3 toEye,
    out float4 ambient, out float4 diffuse, out float4 spec)
{
    // 初始化输出
    ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
    diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
    spec = float4(0.0f, 0.0f, 0.0f, 0.0f);

    // 从表面到光源的向量
    float3 lightVec = L.Position - pos;

    // 表面到光线的距离
    float d = length(lightVec);

    // 灯光范围测试
    if (d > L.Range)
        return;

    // 标准化光向量
    lightVec /= d;

    // 环境光计算
    ambient = mat.Ambient * L.Ambient;

    // 漫反射和镜面计算
    float diffuseFactor = dot(lightVec, normal);

    // 展开以避免动态分支
    [flatten]
    if (diffuseFactor > 0.0f)
    {
        float3 v = reflect(-lightVec, normal);
        float specFactor = pow(max(dot(v, toEye), 0.0f), mat.Specular.w);

        diffuse = diffuseFactor * mat.Diffuse * L.Diffuse;
        spec = specFactor * mat.Specular * L.Specular;
    }

    // 光的衰弱
    float att = 1.0f / dot(L.Att, float3(1.0f, d, d * d));

    diffuse *= att;
    spec *= att;
}
```

### 3）聚光灯

![img](https://img2020.cnblogs.com/blog/1172605/202108/1172605-20210808115853514-543893938.png)

i.聚光灯模型简单介绍：

聚光灯模型与点光模型类似，光照强度会随着与光源距离增大而衰减，其光照强度因子可表示为：
$$
k_{spot}=max(-\vec{L} \cdot \vec{d},0)^{spot}
$$
指数spot表示聚光灯的汇聚程度，值越大汇聚程度越强。

由此我们可以将聚光灯模型表示为：
$$
litColor = k_{spot}(L_a+\frac{L_d+L_s}{a_0+a_1d+a_2d^2})
$$
ii.具体光照计算实现

结构体定义：

```cpp
struct SpotLight
{
    float4 Ambient;
    float4 Diffuse;
    float4 Specular;

    float3 Position;
    float Range;

    float3 Direction;
    float Spot;

    float3 Att;
    float Pad;
};
```

计算光照具体实现：

```cpp
void ComputeSpotLight(Material mat, SpotLight L, float3 pos, float3 normal, float3 toEye,
    out float4 ambient, out float4 diffuse, out float4 spec)
{
    // 初始化输出
    ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
    diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
    spec = float4(0.0f, 0.0f, 0.0f, 0.0f);

    // // 从表面到光源的向量
    float3 lightVec = L.Position - pos;

    // 表面到光源的距离
    float d = length(lightVec);

    // 范围测试
    if (d > L.Range)
        return;

    // 标准化光向量
    lightVec /= d;

    // 计算环境光部分
    ambient = mat.Ambient * L.Ambient;


    // 计算漫反射光和镜面反射光部分
    float diffuseFactor = dot(lightVec, normal);

    // 展开以避免动态分支
    [flatten]
    if (diffuseFactor > 0.0f)
    {
        float3 v = reflect(-lightVec, normal);
        float specFactor = pow(max(dot(v, toEye), 0.0f), mat.Specular.w);

        diffuse = diffuseFactor * mat.Diffuse * L.Diffuse;
        spec = specFactor * mat.Specular * L.Specular;
    }

    // 计算汇聚因子和衰弱系数
    float spot = pow(max(dot(-lightVec, L.Direction), 0.0f), L.Spot);
    float att = spot / dot(L.Att, float3(1.0f, d, d * d));

    ambient *= spot;
    diffuse *= att;
    spec *= att;
}
```

# 3.shader实现

顶点着色器和像素着色器的结构体定义如下：

```cpp
// Light.hlsli
#include "LightHelper.hlsli"

cbuffer VSConstantBuffer : register(b0)
{
    matrix g_World; 
    matrix g_View;  
    matrix g_Proj;  
    matrix g_WorldInvTranspose;
}

cbuffer PSConstantBuffer : register(b1)
{
    DirectionalLight g_DirLight;
    PointLight g_PointLight;
    SpotLight g_SpotLight;
    Material g_Material;
    float3 g_EyePosW;
    float g_Pad;
}


struct VertexIn
{
    float3 PosL : POSITION;
    float3 NormalL : NORMAL;
    float4 Color : COLOR;
};

struct VertexOut
{
    float4 PosH : SV_POSITION;
    float3 PosW : POSITION;     // 在世界中的位置
    float3 NormalW : NORMAL;    // 法向量在世界中的方向
    float4 Color : COLOR;
};
```

顶点着色器实现：

```cpp
// Light_VS.hlsl
#include "Light.hlsli"

// 顶点着色器
VertexOut VS(VertexIn vIn)
{
    VertexOut vOut;
    matrix viewProj = mul(g_View, g_Proj);
    float4 posW = mul(float4(vIn.PosL, 1.0f), g_World);

    vOut.PosH = mul(posW, viewProj);
    vOut.PosW = posW.xyz;
    vOut.NormalW = mul(vIn.NormalL, (float3x3) g_WorldInvTranspose);
    vOut.Color = vIn.Color; // 这里alpha通道的值默认为1.0
    return vOut;
}
```

像素着色器实现：

```cpp
// Light_PS.hlsl
#include "Light.hlsli"

// 像素着色器
float4 PS(VertexOut pIn) : SV_Target
{
    // 标准化法向量
    pIn.NormalW = normalize(pIn.NormalW);

    // 顶点指向眼睛的向量
    float3 toEyeW = normalize(g_EyePosW - pIn.PosW);

    // 初始化为0 
    float4 ambient, diffuse, spec;
    float4 A, D, S;
    ambient = diffuse = spec = A = D = S = float4(0.0f, 0.0f, 0.0f, 0.0f);

    ComputeDirectionalLight(g_Material, g_DirLight, pIn.NormalW, toEyeW, A, D, S);
    ambient += A;
    diffuse += D;
    spec += S;

    ComputePointLight(g_Material, g_PointLight, pIn.PosW, pIn.NormalW, toEyeW, A, D, S);
    ambient += A;
    diffuse += D;
    spec += S;

    ComputeSpotLight(g_Material, g_SpotLight, pIn.PosW, pIn.NormalW, toEyeW, A, D, S);
    ambient += A;
    diffuse += D;
    spec += S;

    float4 litColor = pIn.Color * (ambient + diffuse) + spec;
    
    litColor.a = g_Material.Diffuse.a * pIn.Color.a;
    
    return litColor;
}
```

