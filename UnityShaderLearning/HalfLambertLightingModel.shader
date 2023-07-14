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
                //������
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //���巨��
                fixed3 worldNormal = normalize(vOut.worldNormal);
                //���շ���
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //���������䣨�������ع���ģ�ͣ�
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
