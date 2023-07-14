// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

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
