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

            //�𶥵���������գ�ʹ�ö�����ɫ����
            vertOut vert(vertIn vIn)
            {
                vertOut vOut;
                vOut.pos = UnityObjectToClipPos(vIn.vertex);

                //��ȡ����������
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //�����巨��������ģ�Ϳռ�ת��������ռ�
                fixed3 worldNormal = normalize(mul(vIn.normal, (float3x3)unity_WorldToObject));

                //��ȡ���շ�������
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //���㻷���⣨lambert's law��
                //����saturate�������ڽ���Χ������[0,1]���൱�ڶ����е�'max'
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
