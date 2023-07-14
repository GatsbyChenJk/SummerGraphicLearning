// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

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
