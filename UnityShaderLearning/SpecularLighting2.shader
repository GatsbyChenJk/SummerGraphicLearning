// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

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
