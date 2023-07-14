Shader "Unlit/NormalShader"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    //第一种法线贴图实现方式：在切线空间中计算
    SubShader
    {
       Tags { "LightMode" = "ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag          
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct vertIn
            {
             float4 vertex : POSITION;
             float3 normal : NORMAL;
             float4 tangent : TANGENT;
             float4 texcoord : TEXCOORD0;
            };

            struct vertOut
            {
             float4 pos : SV_POSITION;
             float4 uv : TEXCOORD0;
             float3 lightDir : TEXCOORD1;
             float3 viewDir : TEXCOORD2; 
            };

            vertOut vert(vertIn vIn)
            {
              vertOut vOut;
              vOut.pos = UnityObjectToClipPos(vIn.vertex);
              //获取纹理和法线贴图偏移量
              vOut.uv.xy = vIn.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
              vOut.uv.zw = vIn.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

              //计算副切线
              float3 binormal = cross( normalize(vIn.normal), normalize(vIn.tangent.xyz))
              * vIn.tangent.w;

              //构建将模型空间转换为切线空间的变换矩阵
              float3x3 rotation = float3x3(vIn.tangent.xyz, binormal, vIn.normal);
              //or : TANGENT_SPACE_ROTATION

              //将光照方向向量由模型空间变换到切线空间
              vOut.lightDir = mul(rotation, ObjSpaceLightDir(vIn.vertex)).xyz;
              //将观察方向向量由模型空间变换到切线空间
              vOut.viewDir = mul(rotation,ObjSpaceViewDir(vIn.vertex)).xyz;

              return vOut;
            }

            fixed4 frag(vertOut vOut) : SV_Target
            {
              fixed3 tangentLightDir = normalize(vOut.lightDir);
              fixed3 tangentViewDir = normalize(vOut.viewDir);

              //获取法线贴图的纹理单元（纹素texel）
              fixed4 packedNormal = tex2D(_BumpMap,vOut.uv.zw);
              fixed3 tangentNormal;


              //将纹理标记为法线贴图，使用内置函数
              tangentNormal = UnpackNormal(packedNormal);
              tangentNormal.xy *= _BumpScale;
              tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
              //在切线空间条件下计算光照(Blinn Phong)
              fixed3 albedo = tex2D(_MainTex, vOut.uv).rgb * _Color.rgb;

              fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

              fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal,tangentLightDir));

              fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

              fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, 
              halfDir)), _Gloss);

              return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
