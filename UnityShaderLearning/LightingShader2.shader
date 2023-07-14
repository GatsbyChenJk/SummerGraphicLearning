// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

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
            //�˴�������ֵ�ṹ���е���ɫ��Ϊ��������
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
            //�����ؼ��㻷���⣨ʹ��ƬԪ��ɫ����
            fixed4 frag(vertOut vOut) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //��ȡ��������
                fixed3 worldNormal = normalize(vOut.worldNormal);
                //��ȡ���߷�������
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //���㻷����(lambert's law)
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
