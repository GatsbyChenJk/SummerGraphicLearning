# unity基本光照shader学习笔记

# 一、漫反射

## 1.漫反射模型基础理论

兰伯特定律（lambert‘s law）
$$
c_{diffuse}=(c_{light}\cdot m_{diffuse})max(0,\hat{n}\cdot\vec{I})
$$
其中c_{light}表示环境光光照强度，m_{diffuse}表示漫反射光光照系数，n为物体的法线向量，I为光照方向向量

## 2漫反射shader的两种实现

1）逐顶点实现，使用像素着色器进行计算

```cpp
Shader "Unlit/LightingShader"
{
    Properties
    {
       _Diffuse("Diffuse",Color) = (1, 1, 1, 1)
    }
        SubShader
    {
        Pass
        {

            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            
            struct vertIn
            { 
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct vertOut
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            //逐顶点漫反射光照（使用顶点着色器）
            vertOut vert(vertIn vIn)
            {
                vertOut vOut;
                vOut.pos = UnityObjectToClipPos(vIn.vertex);

                //获取环境光属性
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //将物体法线向量从模型空间转换到世界空间
                fixed3 worldNormal = normalize(mul(vIn.normal, (float3x3)unity_WorldToObject));

                //获取光照方向向量
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //计算环境光（lambert's law）
                //其中saturate函数用于将范围限制在[0,1]，相当于定律中的'max'
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
                    worldLight));

                vOut.color = ambient + diffuse;

                return vOut;
            }

            fixed4 frag(vertOut vOut) : SV_Target
            {
                return fixed4(vOut.color, 1.0);
            }
        
            ENDCG
        }     
    }
        FallBack "Diffuse"
}
```

2）逐像素实现，使用片元着色器

```cpp
Shader "Unlit/LightingShader2"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
        SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct vertIn
            { 
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            //此处将返回值结构体中的颜色改为法线向量
            struct vertOut
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            vertOut vert(vertIn vIn)
            {
                vertOut vOut;

                vOut.pos = UnityObjectToClipPos(vIn.vertex);

                vOut.worldNormal = mul(vIn.normal, (float3x3)unity_WorldToObject);

                return vOut;
            }
            //逐像素计算环境光（使用片元着色器）
            fixed4 frag(vertOut vOut) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //获取法线向量
                fixed3 worldNormal = normalize(vOut.worldNormal);
                //获取光线方向向量
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算环境光(lambert's law)
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
                    worldLightDir));

                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);

            }


            ENDCG
        }
    }
        FallBack "Diffuse"
}

```

## 3.两种实现的效果展示

1）逐顶点

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711203841355.png)

2）逐像素

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711203902928.png)

可见两种实现方式都有一定问题，前者在明暗交界处有明显的锯齿，而后者明与暗之间没有过度，显得不自然，于是这里的解决方案就是半兰伯特模型

## 4.半兰伯特模型

该模型由V社在开发游戏《半条命》时提出，是兰伯特光照模型的修正，表达式如下：
$$
c_{diffuse}=(c_{light}\cdot m_{diffuse})(\alpha(\hat{n}\cdot\vec{I})+\beta)
$$
其中阿尔法和贝塔通常为0.5，在unity的实现中对于漫反射的计算可以修改成如下形式：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711210422248.png)

效果如图：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711210442644.png)

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711210458239.png)

# 二、高光（镜面）反射

## 1.Phong模型

Phong模型是一种基础的高光反射模型，其表达式如下：
$$
c_{specular}=(c_{light} \cdot m_{specular})max(0,\hat{v} \cdot \vec{r})^{m_{gloss}}
$$
其中c_{light}表示光照强度，m_{specular}表示高光（或镜面）反射系数，一般由颜色值rgb决定，单位向量v表示观察方向，r表示光照经过物体表面反射后的方向，计算公式为：
$$
\vec{r}=2(\hat{n} \cdot \vec{I})\hat{n}-\vec{I}
$$
m_{gloss}表示高光强度，也即材质的光泽度。

## 2.Phong模型的unity实现

1）第一种实现方式，逐顶点实现

```cpp
Shader "Unlit/SpecularLighting"
{
    Properties
    {
       _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
       _Specular("Specular", Color) = (1, 1, 1, 1)
       _Gloss("Gloss", Range(8.0, 256)) = 20
    }
        SubShader
    {
       Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            fixed3 _Diffuse;
            fixed3 _Specular;
            float _Gloss;

            struct vertIn
            {
             float4 vertex : POSITION;
             float3 normal : NORMAL;
            };
      
            struct vertOut
            { 
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };
            //逐顶点实现基本高光反射光照模型
            vertOut vert(vertIn vIn)
            {
                vertOut vOut;
                vOut.pos = UnityObjectToClipPos(vIn.vertex);
                //获取环境光属性
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //变换(get)法线向量
                fixed3 worldNormal = normalize(mul(vIn.normal, (float3x3)unity_WorldToObject));
                //获取光照方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算漫反射光照
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
                    worldLightDir));

                //获取反射光线方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                //获取视角（观察）方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, vIn.vertex).xyz);
                //计算高光反射光照（Phong）
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                vOut.color = ambient + diffuse + specular;

                return vOut;
            }

            fixed4 frag(vertOut vOut) : SV_Target
            {
                return fixed4(vOut.color, 1.0);
            }
           
            ENDCG
        }
    }
        Fallback "Specular"
}
```

2）第二种实现，逐像素实现

```cpp
Shader "Unlit/SpecularLighting2"
{
    Properties
    {
       _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
       _Specular("Specular", Color) = (1, 1, 1, 1)
       _Gloss("Gloss",Range(8.0, 256)) = 20
    }
        SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag         
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed3 _Diffuse;
            fixed3 _Specular;
            float _Gloss;

            struct vertIn
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct vertOut
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            vertOut vert(vertIn vIn)
            {
                vertOut vOut;
                vOut.pos = UnityObjectToClipPos(vIn.vertex);
                //计算法线方向，用于传递给片元着色器
                vOut.worldNormal = mul(vIn.normal, (float3x3)unity_WorldToObject);
                //获取顶点的世界空间坐标，用于计算观察方向
                vOut.worldPos = mul(unity_ObjectToWorld, vIn.vertex).xyz;
                
                return vOut;
            }
            //逐像素计算基本高光反射模型
            fixed4 frag(vertOut vOut) : SV_Target
            {
                //获取漫反射各个属性的值
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(vOut.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                //计算高光反射各个属性的值
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vOut.worldPos.xyz);
                //计算高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)),
                    _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
        Fallback "Specular"
}
```

3）两种实现方式效果如下：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230713114258922.png)

（左：逐顶点  ； 右：逐像素）

可见逐顶点实现锯齿感明显，逐像素实现平滑许多，但是亮点范围小

## 3.Blinn-Phong模型

为了获得更大的高亮，我们使用Blinn基于phong模型的修正得到的布林冯模型，与Phong模型不同的一点在于我们无需计算反射光线的方向，而是计算观察方向和入射光的角平分线方向，也称为半程向量，计算方式如下：
$$
\hat{h}=\frac{\vec{v}+\vec{I}}{||\vec{v}+\vec{I}||}
$$
则Blinn-Phong模型的具体表示为：
$$
c_{Blinn-Phong}=(c_{light} \cdot m_{specular})max(0,\hat{n} \cdot \hat{h})^{m_{gloss}}
$$

# 4.Blinn-Phong模型的unity实现

布林冯模型的实现是Phong模型中逐像素实现的改进，因此我们只需在逐像素实现的片元着色器做修改即可。

修改的部分为：

```cpp
 //计算布林冯高光反射各个属性的值 
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vOut.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);           
                //计算Blinn Phong高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)),
                    _Gloss);
```

效果与两种Phong模型对比如下：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230713160057742.png)

图中最右侧的即为布林冯模型实现的效果，可见其具有更大范围的高光效果。
