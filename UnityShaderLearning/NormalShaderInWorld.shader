// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/NormalShaderInWorld"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
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
              float4 TtoW0 : TEXCOORD1;
              float4 TtoW1 : TEXCOORD2;
              float4 TtoW2 : TEXCOORD3;
            };

            vertOut vert(vertIn vIn)
            {
             vertOut vOut;
             vOut.pos = UnityObjectToClipPos(vIn.vertex);
             //偏移
             vOut.uv.xy = vIn.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
             vOut.uv.zw = vIn.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
             //计算变换矩阵各行分量
             float3 worldPos = mul(unity_ObjectToWorld, vIn.vertex).xyz;
             fixed3 worldNormal = UnityObjectToWorldNormal(vIn.normal);
             fixed3 worldTangent = UnityObjectToWorldDir(vIn.tangent.xyz);
             fixed3 worldBinormal = cross(worldNormal,worldTangent) * vIn.tangent.w;

             //存储计算的分量
             vOut.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
             vOut.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
             vOut.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

             return vOut;
             
            }

            fixed4 frag(vertOut vOut) : SV_Target
            {
              //获取物体的世界空间坐标
              float3 worldPos = float3(vOut.TtoW0.w, vOut.TtoW1.w, vOut.TtoW2.w);
              //计算光照方向和观察方向
              fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
              fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

              //获取切线空间的法线
              fixed3 bump = UnpackNormal(tex2D(_BumpMap, vOut.uv.zw));
              bump.xy *= _BumpScale;
              bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
              //将法线由切线空间坐标变换到世界空间坐标
              bump = normalize(half3(dot(vOut.TtoW0.xyz, bump),
              dot(vOut.TtoW1.xyz, bump),
              dot(vOut.TtoW2.xyz, bump)));

              //计算光照(环境光、 漫反射和高光)
              fixed3 albedo = tex2D(_MainTex, vOut.uv).rgb * _Color.rgb;
              fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
              fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
              fixed3 halfDir = normalize(lightDir + viewDir);
              fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)),
              _Gloss);

              return fixed4(ambient + diffuse + specular, 1.0);
            }
         
            ENDCG
        }
    }
}
