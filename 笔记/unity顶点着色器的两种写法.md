# HLSL顶点着色器的两种写法

### 1）简易写法

```cpp
float4 vert (float4 vertex : POSITION) : SV_POSITION
      {
        return mul(UNITY_MATRIX_MVP, vertex);
      }
```

理解如下：

这段代码是一个顶点着色器函数，用于将输入的顶点位置转换为裁剪空间中的位置。让我逐行解释一下代码的含义：

1. `float4 vert (float4 vertex : POSITION) : SV_POSITION`：这是顶点着色器函数的声明。它接受一个名为`vertex`的输入参数，类型为`float4`，表示顶点的位置。函数的返回类型是`float4`，表示变换后的顶点位置，同时使用`SV_POSITION`语义指定该值将被用作顶点的裁剪空间位置。

2. `return mul(UNITY_MATRIX_MVP, vertex);`：这行代码使用了Unity的内置变换矩阵`UNITY_MATRIX_MVP`，将输入顶点位置`vertex`进行变换。`UNITY_MATRIX_MVP`是一个包含模型、视图和投影变换的矩阵，它将顶点从模型空间转换到裁剪空间。`mul`函数用于执行矩阵乘法运算，将顶点位置与变换矩阵相乘得到变换后的位置。

综上所述，这段代码的作用是将输入的顶点位置从模型空间转换到裁剪空间，并返回变换后的位置作为顶点的裁剪空间位置。

补充：

1.冒号在输入参数`float4 vertex : POSITION`的作用：指定参数的语义（Semantic）：冒号后面的标识符用于指定参数的语义，即参数的作用或含义。在顶点着色器函数中，常见的语义包括`POSITION`、`NORMAL`、`TEXCOORD`等。语义的选择取决于参数所代表的数据类型和用途。

2.冒号在`: SV_POSITION`处的作用：`SV_POSITION`语义指定函数返回值将被用作顶点的裁剪空间位置。

### 2）复杂写法

首先需要定义接收输入值（顶点坐标和uv）的结构体：

```cpp
 struct appdata
       {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
       };
```

接着定义返回值的结构体：

```cpp
struct v2f
        {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
        };
```

然后是着色器代码：

```cpp
sampler2D _MainTex;
float4 _MainTex_ST;
            
      v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
```

