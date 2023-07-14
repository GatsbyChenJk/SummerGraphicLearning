Shader "Unlit/TextureWithBlinnPhong"
{
 Properties
    {
       _Color("Color Tint", Color) = (1, 1, 1, 1)
       _MainTex ("Main Tex", 2D) = "white" {}
       _Specular("Specular", Color) = (1, 1, 1, 1)
       _Gloss("Gloss",Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags {  "LightMode" = "ForwardBase"  }
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            float4 _MainTex_ST;
            sampler2D _MainTex;

            struct vertIn
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct vertOut
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            vertOut vert(vertIn vIn)
            {
                vertOut vOut;
                vOut.pos = UnityObjectToClipPos(vIn.vertex);
                //���㷨�߷������ڴ��ݸ�ƬԪ��ɫ��
                vOut.worldNormal = mul(vIn.normal, (float3x3)unity_WorldToObject);
                //��ȡ���������ռ����꣬���ڼ���۲췽��
                vOut.worldPos = mul(unity_ObjectToWorld, vIn.vertex).xyz;

                vOut.uv = vIn.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //or : vOut.uv = TRANSFORM_TEX(vIn.texcoord, _MainTex);

                return vOut;
            }
            //���ַ����ģ��
            fixed4 frag(vertOut vOut) : SV_Target
            {
                //��ȡ������������Ե�ֵ             
                fixed3 worldNormal = normalize(vOut.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //calculate the albedo(������) value
                fixed3 albedo = tex2D(_MainTex, vOut.uv).rgb * _Color.rgb;
                //then the ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                //����������
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
                //���㲼�ַ�߹ⷴ��������Ե�ֵ 
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vOut.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);           
                //����Blinn Phong�߹ⷴ��
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)),
                    _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }


          
            ENDCG
        }
    }
        Fallback "Specular"
}
