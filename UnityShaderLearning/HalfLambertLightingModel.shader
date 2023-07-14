Shader "Unlit/HalfLambertLightingModel"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1, 1, 1, 1)
    }
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

            fixed4 _Diffuse;

            struct vertIn
            { 
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

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

            fixed4 frag(vertOut vOut) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //物体法线
                fixed3 worldNormal = normalize(vOut.worldNormal);
                //光照方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算漫反射（半兰伯特光照模型）
                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);
                
            }
           
            ENDCG
        }
    }
        FallBack "Diffuse"
}
